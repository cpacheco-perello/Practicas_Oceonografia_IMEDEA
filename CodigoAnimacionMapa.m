close all;
clear;
%% PARAMETROS EJECUCION 

tic;

numshade = 4; % Number of days for shadow
colorCic= [0, 0, 1]; % Color for points ciclonic
colorAnc= [1,0, 0];  % Color for points anticiclonic

%%Define the time range for animation
start_date = datetime(1950, 1, 1);   % INICIO DE LA CUENTA DE DIAS DE LOS DATOS
dates = datetime(2000, 9, 1);    % Fecha inicio a representar (1993 primer año)
dates_END = datetime(2000, 9, 30);  
days_since_start = days(dates - start_date);% Fecha inicio a representar en dias desde start_date
days_since_start_END = days(dates_END - start_date); 
% Intervalo representación
time = [days_since_start, days_since_start_END]; 

%%Variable para rellenar los eddys
fieldName = 'lifetime';
TituloColorbar="Lifetime (Days)";
%%Numero de veces que sera un plot un frame en el video
numFrameVideo=4;



%% CARGA DE DATOS 
% carpeta donde estan los archivos
folderPath = 'C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo';
% nombre de los archivos de datos ciclonica y anticiclonica
filenameAnticiclonica = 'Data_Anticiclonica_short_long_combinado.mat';
filenameCiclonica = 'Data_Cicllonica_short_long_combinado.mat';

% archivos de datos ciclonica y anticiclonica
mat_filenameANC = fullfile(folderPath, filenameAnticiclonica);
mat_filenameCIC = fullfile(folderPath, filenameCiclonica);
% nombre de los archivos de datos ciclonica y anticiclonica
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
countries = readgeotable("C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS" + ...
    "\\ne_10m_admin_0_countries\ne_10m_admin_0_countries.shp");

%% Create a video and gif object for saving the animation
vidObj = VideoWriter('animacion_mapas_con_fade', 'MPEG-4');
vidObj.Quality = 100;
vidObj.FrameRate = 60; % Adjust frame rate as needed
open(vidObj);

% Configuración para guardar GIF
vid_filename = 'animacion_mapas.avi'; % Nombre del archivo de video
gif_filename = 'animacion_mapas.gif'; % Nombre del archivo GIF


%% Variable min and max for area fill of eddys
idxC = find(Data_CIC.time >= time(1) & Data_CIC.time <= time(2)); % Para Data_CIC
idxA = find(Data_ANC.time >= time(1) & Data_ANC.time <= time(2)); % Para Data_ANC

minLifetime = min(min(Data_ANC.(fieldName)(idxA)),min(Data_CIC.(fieldName)(idxC)));  % Encuentra el valor mínimo
maxLifetime = max(max(Data_ANC.(fieldName)(idxA)),max(Data_CIC.(fieldName)(idxC)));  % Encuentra el valor máximo
if maxLifetime<80
 cmap=parula(maxLifetime);
else 
    cmap=parula(80);
end


%%  Loop over the time range
figure('Position', [100, 100, 1920, 1080], 'Color', 'white');
for dia = time(1):time(2)

     %% Mundo i condiciones de figura
     
     % Configuración del mapa

    ax = worldmap([lat_min_bound lat_max_bound], [long_min_bound long_max_bound]);
    setm(ax, 'Frame', 'on', 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on');

    % Show country borders
    geoshow(countries, 'FaceColor', [0.3 0.4 0.3], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1,'Parent', ax);
 
    %% Loop for both CIC and ANC
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
    
    for k = 1:length(fields_ANC)     %para cada dia almacenado
        
        dayANC = Data_Dias_ANC.(fields_ANC{k});
        dayCIC = Data_Dias_CIC.(fields_ANC{k});
        alpha =feval(alphaF,k);
        tam =feval(tamF,k);
        tam_line = feval(tam_lineF,k);

        % Plot points for both CIC and ANC
        if ~isempty(dayANC)
            scatterm(dayANC.latitude, dayANC.longitude, tam, 'MarkerFaceColor', colorAnc, 'MarkerEdgeColor', 'none');
            scatterm(dayCIC.latitude, dayCIC.longitude, tam, 'MarkerFaceColor', colorCic, 'MarkerEdgeColor', 'none');
        end

        % Plot individual contours for both CIC and ANC
        for i = 1:size(dayANC.effective_contour_latitude, 2)
            latA = dayANC.effective_contour_latitude(:, i);
            lonA = dayANC.effective_contour_longitude(:, i);
          
            geoshow(latA, lonA, 'DisplayType', 'line', 'Color', [colorAnc, alpha], 'LineWidth', tam_line);

            % RELLENA CON LA VARIABLE EXTRA
            if k==1
                % Normaliza el valor 
                lifetime_value = dayANC.(fieldName)(i);
                index = round((lifetime_value - minLifetime) / (maxLifetime - minLifetime) * (size(cmap, 1) - 1)) + 1;
                
                % Extrae el color correspondiente
                color = cmap(index, :);
                % Dibuja el polígono con relleno
                fillm(latA, lonA,'FaceColor' ,color, ...  % Azul como color de relleno
                    'FaceAlpha', 0.6, ...         % Transparencia
                    'EdgeColor', 'none'); 
            end
        end


        for i = 1:size(dayCIC.effective_contour_latitude, 2)
            latC = dayCIC.effective_contour_latitude(:, i);
            lonC = dayCIC.effective_contour_longitude(:, i);
            geoshow(latC, lonC, 'DisplayType', 'line', 'Color', [colorCic, alpha], 'LineWidth', tam_line);

            if k==1
                % Normaliza el valor 
                lifetime_value = dayCIC.(fieldName)(i);
                index = round((lifetime_value - minLifetime) / (maxLifetime - minLifetime) * (size(cmap, 1) - 1)) + 1;
                
                % Extrae el color correspondiente
                color = cmap(index, :);
                % Dibuja el polígono con relleno
             
                fillm(latC, lonC,'FaceColor' ,color, ...  % Azul como color de relleno
                    'FaceAlpha', 0.6, ...         % Transparencia
                    'EdgeColor', 'none'); 
              
            end

        end
    end
    

     
     for num = numshade:-1:1  
        % Asigna los datos de Data_Dia_{num-1}D a Data_Dias con el nombre dinámico
        if isfield(Data_Dias_CIC, ['Data_Dia_' num2str(num-1) 'D'])
            Data_Dias_CIC.(['Data_Dia_' num2str(num) 'D']) =Data_Dias_CIC.(['Data_Dia_' num2str(num-1) 'D']);
            Data_Dias_ANC.(['Data_Dia_' num2str(num) 'D']) =Data_Dias_ANC.(['Data_Dia_' num2str(num-1) 'D']);
        end
    end


   
    %% Representacion 
    % TITULO --
   
    dia_Actual_Fecha = start_date + days(dia);
    title(['Mapa del Mediterráneo  Fecha: ' datestr(dia_Actual_Fecha)] , 'FontSize', 16);

    % Crear un objeto gráfico vacío para la leyenda del color anticiclónico (rojo)
    h_legend_anticiclonico = plot(NaN, NaN, 'o', 'MarkerFaceColor', colorAnc, 'MarkerEdgeColor', 'none');
    
    % Crear un objeto gráfico vacío para la leyenda del color ciclónico (azul)
    h_legend_ciclonico = plot(NaN, NaN, 'o', 'MarkerFaceColor', colorCic, 'MarkerEdgeColor', 'none');
    
    % Añadir la leyenda manualmente
    legend([h_legend_anticiclonico, h_legend_ciclonico], ...
    {'Anticiclónico', 'Ciclónico'}, ...
    'Location', 'northoutside', 'FontSize', 12);

    % colorbar ---
    colormap(cmap);
    clim([minLifetime ,maxLifetime]);  
    
    % Muestra la barra de colores
    cb = colorbar; 

    cb.Title.String=(TituloColorbar);
    cb.Title.FontSize = 12;

    % Ajusta la transparencia del colorbar


    % Opcional: puedes ajustar la posición del colorbar si lo deseas
    % cb.Position = [0.85, 0.1, 0.03, 0.8];  % Ajusta la posición del colorbar

    
    

    
    %% CAPTURA DE FRAME Y GUARDADO DE VIDEO 
    frame = getframe(gcf); 
    numF=1;
    while numF<=numFrameVideo
        writeVideo(vidObj, frame);
        numF=numF+1;
    end
   
    img = frame2im(frame); % Convertir el cuadro a imagen RGB
    [imind, cm] = rgb2ind(img, 256); % Convertir a índice de color (para GIF)
    % Pausa para controlar la velocidad de la animación
    %pause(0.1);
     % Guardar en el archivo GIF
    if dia == time(1)
        % Crear el archivo GIF en la primera iteración
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.15);
    else
        % Agregar cuadros al GIF en las iteraciones posteriores
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.15);
    end
    
    % Limpiar la figura para la siguiente iteración
    clf;
end

% Close the video object
close(vidObj);

% Detiene el cronómetro y muestra el tiempo transcurrido
elapsedTime = toc;
fprintf('Tiempo de ejecución: %.4f segundos\n', elapsedTime);
