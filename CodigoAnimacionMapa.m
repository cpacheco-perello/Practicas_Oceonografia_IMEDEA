close all;
clear;

folderPath = 'C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo';
filenameAnticiclonica = 'Data_twosat_Anticyclonic_long__Mediterraneo.mat';
filenameCiclonica = 'Data_twosat_Cyclonic_long__Mediterraneo.mat';

mat_filenameANC = fullfile(folderPath, filenameAnticiclonica);
mat_filenameCIC = fullfile(folderPath, filenameCiclonica);

% Load the .mat files
Data_CIC = load(mat_filenameCIC);
Data_ANC = load(mat_filenameANC);

% Get the field names of the structs
campos_CIC = fields(Data_CIC);
campos_ANC = fields(Data_ANC);

% Access the first variable inside the struct
Data_CIC = Data_CIC.(campos_CIC{1});
Data_ANC = Data_ANC.(campos_ANC{1});

%% Geographical bounds (expanded Mediterranean region)
long_min_bound = -10;
long_max_bound = 45;
lat_min_bound = 27;
lat_max_bound = 50;

% Read the shapefile for country boundaries
countries = readgeotable("C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\\ne_10m_admin_0_countries\ne_10m_admin_0_countries.shp");

% Create a video object for saving the animation
vidObj = VideoWriter('animacion_mapas_con_fade', 'Motion JPEG AVI');
vidObj.Quality = 100;
vidObj.FrameRate = 60; % Adjust frame rate as needed
open(vidObj);

% Figure setup for animation
% Configuración para guardar video y GIF
vid_filename = 'animacion_mapas.avi'; % Nombre del archivo de video
gif_filename = 'animacion_mapas.gif'; % Nombre del archivo GIF

%% Define el mapa de colores (puedes cambiarlo a otro mapa si lo prefieres)
minLifetime = min(min(Data_ANC.lifetime),min(Data_CIC.lifetime));  % Encuentra el valor mínimo
maxLifetime = max(max(Data_ANC.lifetime),max(Data_CIC.lifetime));  % Encuentra el valor máximo

cmap = parula(256);  % Mapa de colores 'parula'


% Define the time range for animation
numshade = 4; % Number of days for shadow
colorCic= [1, 0, 0]; % Color for points
colorAnc= [0,0, 1]; 

start_date = datetime(1950, 1, 1);
dates = datetime(1993, 1, 1);
days_since_start = days(dates - start_date);
time = [days_since_start, days_since_start + 30]; % Interval for animation


%%  Loop over the days in the time range
for dia = time(1):time(2)
    set(gcf, 'Position', [100, 100, 1920, 1080]);
    
    worldmap([lat_min_bound lat_max_bound], [long_min_bound long_max_bound]);
    setm(gca, 'Frame', 'on', 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on');

    % Show country borders
    geoshow(countries, 'FaceColor', [0.3 0.4 0.3], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1);
    
    % Loop for both CIC and ANC
    for Turno = [1, 2]
        if Turno == 1
            Data = Data_CIC;
            idx = find(Data_CIC.time == dia);
        else
            Data = Data_ANC;
            idx = find(Data_ANC.time == dia);
        end

        Data_Dia_0D.latitude = Data.latitude(idx);
        Data_Dia_0D.longitude = Data.longitude(idx);
        Data_Dia_0D.effective_contour_latitude = Data.effective_contour_latitude(:, idx);
        Data_Dia_0D.effective_contour_longitude = Data.effective_contour_longitude(:, idx);
        Data_Dia_0D.lifetime = Data.lifetime(idx);

        % Store data for each type
        if Turno == 1
            Data_Dias_CIC.Data_Dia_0D = Data_Dia_0D;
        else
            Data_Dias_ANC.Data_Dia_0D = Data_Dia_0D;
        end
    end

    % Loop through fields to plot the data for each day
    fields_ANC = fieldnames(Data_Dias_ANC);
      
    alphaF=@(x)  1 - (x - 1) / length(fields_ANC);
    tamF =@(x) 36 - 36 * (x - 1) / length(fields_ANC);
    tam_lineF =@(x) 2 - 2 * (x - 1) / length(fields_ANC);
    
    for k = 1:length(fields_ANC)
        
        dayANC = Data_Dias_ANC.(fields_ANC{k});
        dayCIC = Data_Dias_CIC.(fields_ANC{k});
        alpha =alphaF(k);
        tam =tamF(k);
        tam_line = tam_lineF(k);

        % Plot points for both CIC and ANC
        if ~isempty(dayANC)
            scatterm(dayANC.latitude, dayANC.longitude, tam, 'MarkerFaceColor', colorAnc, 'MarkerEdgeColor', 'none');
            scatterm(dayCIC.latitude, dayCIC.longitude, tam, 'MarkerFaceColor', colorCic, 'MarkerEdgeColor', 'none');
        end

        % Plot contours for both CIC and ANC
        for i = 1:size(dayANC.effective_contour_latitude, 2)
            latA = dayANC.effective_contour_latitude(:, i);
            lonA = dayANC.effective_contour_longitude(:, i);
            if latA(1) ~= latA(end) || lonA(1) ~= lonA(end)
                latA(end+1) = latA(1);
                lonA(end+1) = lonA(1);
            end
          
            geoshow(latA, lonA, 'DisplayType', 'line', 'Color', [colorAnc, alpha], 'LineWidth', tam_line);
            if k==1
            % Normaliza el valor de lifetime
            lifetime_value = dayANC.lifetime(i);
            index = round((lifetime_value - minLifetime) / (maxLifetime - minLifetime) * (size(cmap, 1) - 1)) + 1;
            
            % Extrae el color correspondiente
            color = cmap(index, :);
            % Dibuja el polígono con relleno
            fillm(latA, lonA,'FaceColor' ,color, ...  % Azul como color de relleno
                'FaceAlpha', 0.9, ...         % Transparencia
                'EdgeColor', 'none'); 
            end
        end

        for i = 1:size(dayCIC.effective_contour_latitude, 2)
            latC = dayCIC.effective_contour_latitude(:, i);
            lonC = dayCIC.effective_contour_longitude(:, i);
            geoshow(latC, lonC, 'DisplayType', 'line', 'Color', [colorCic, alpha], 'LineWidth', tam_line);
        end
    end
    

     
     for num = numshade:-1:1  
        % Asigna los datos de Data_Dia_{num-1}D a Data_Dias con el nombre dinámico
        if isfield(Data_Dias_CIC, ['Data_Dia_' num2str(num-1) 'D'])
            Data_Dias_CIC.(['Data_Dia_' num2str(num) 'D']) =Data_Dias_CIC.(['Data_Dia_' num2str(num-1) 'D']);
            Data_Dias_ANC.(['Data_Dia_' num2str(num) 'D']) =Data_Dias_ANC.(['Data_Dia_' num2str(num-1) 'D']);
        end
    end

%% Representación 
   
   
    dia_Actual_Fecha = start_date + days(dia);
    colormap(cmap);
    colorbar

    title(['Mapa del Mediterráneo  Fecha: ' datestr(dia_Actual_Fecha)] );
    
    % Capturar el cuadro de la figura actual
    frame = getframe(gcf); 
    writeVideo(vidObj, frame); % Escribir el cuadro en el archivo de video
    img = frame2im(frame); % Convertir el cuadro a imagen RGB
    [imind, cm] = rgb2ind(img, 256); % Convertir a índice de color (para GIF)
    % Pausa para controlar la velocidad de la animación
    %pause(0.1);
     % Guardar en el archivo GIF
    if dia == time(1)
        % Crear el archivo GIF en la primera iteración
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        % Agregar cuadros al GIF en las iteraciones posteriores
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
    
    % Limpiar la figura para la siguiente iteración
    clf;
end

% Close the video object
close(vidObj);
