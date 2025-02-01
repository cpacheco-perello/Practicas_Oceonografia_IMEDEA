close all;
clear all;
folderPath = 'C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo';
filenameAnticiclonica = 'Data_Anticiclonica_short_long_combinado.mat';
filenameCiclonica = 'Data_Cicllonica_short_long_combinado.mat';

mat_filenameANC = fullfile(folderPath, filenameAnticiclonica);
mat_filenameCIC = fullfile(folderPath, filenameCiclonica);
load("CELDAS.mat")
%% Load the .mat files
Data_CIC = load(mat_filenameCIC);
Data_ANC = load(mat_filenameANC);

% Get the field names of the structs
campos_CIC = fields(Data_CIC);
campos_ANC = fields(Data_ANC);

% Access the first variable inside the struct
Data_CIC = Data_CIC.(campos_CIC{1});
Data_ANC = Data_ANC.(campos_ANC{1});

%% BUCLE
% Crear un arreglo de celdas para iterar
datasets = {Data_ANC, Data_CIC};

% Bucle para procesar cada estructura
for k = 1:length(datasets)
    Data = datasets{k}; % Selecciona la estructura actual


%% LIFETIME
%{
    % Inicialización del contador
    contador = zeros(size(Data.time)); % Asegúrate de que 'time' exista en tus datos
    contador(1) = 1; % El primer elemento empieza con 1
    % Recorre los datos y cuenta
    for i = 2:length(Data.time)
        if Data.track(i) == Data.track(i-1) % Compara con el elemento anterior
            contador(i) = contador(i-1) + 1; % Incrementa si es igual
        else
            contador(i) = 1; % Reinicia el contador si cambia
        end
    end

    % Agregar el contador como un nuevo campo 'lifetime'
    Data.lifetime = contador;
%}

%% CELDA DE NACIMIENTO
%{
track = unique(Data.track);

% Iterar sobre cada valor único en 'track'
for j = 1:length(track)
    % Acceder al valor de track en la posición j
    track_value = track(j);
% Paso 1: Obtener el valor mínimo de la columna 'track'

    idx=find(Data.track == track_value);
    % Paso 2: Filtrar las filas donde el valor de 'track' es igual al valor mínimo
    latitud= (Data.latitude(idx));
    latitud_origen=latitud(1);

    longitud= (Data.longitude(idx));
    longitud_origen=longitud(1);

    % Obtener las coordenadas del punto a verificar

    % Crear un punto en las coordenadas de latitud y longitud
    point = geopointshape(latitud_origen, longitud_origen);

    % Definir el tamaño de la celda en grados
    cell_size = 1; 
    for u = 1:length(cells)
        lon=cells(u).Longitude;
        lat=cells(u).Latitude;
        % Crear los vértices del cuadrado (polígono de la celda)
        lon_points = [lon, lon + cell_size, lon + cell_size, lon];  % Coordenadas de longitud
        lat_points = [lat, lat, lat + cell_size, lat + cell_size];  % Coordenadas de latitud

    % Crear el polígono de la celda usando geoshape
        cell_polygon = geopolyshape(lat_points, lon_points);
    
        % Verificar si el punto está dentro del polígono de la celda
        
        if isinterior(cell_polygon, point)
            Data.celda(idx, 1)=u;
            break
        end 

    end
 end
%}

    
%% CELDA DE NACIMIENTO PARA LOS QUE NO SE LES HA ASIGNADO
%{
idx = find(Data.celda == 0); % Encuentra índices donde Data.celda es 0

for j = idx
    latitud_origen = Data.latitude(j);
    longitud_origen = Data.longitude(j);
    point = geopointshape(latitud_origen, longitud_origen);
    
    cell_size = 1; 
    min_distance = inf; % Inicializa la distancia mínima con infinito
    closest_cell = -1; % Variable para almacenar la celda más cercana

    for u = 1:length(cells)
        lon = cells(u).Longitude;
        lat = cells(u).Latitude;

        % Crear los vértices del cuadrado (polígono de la celda)
        lon_points = [lon, lon + cell_size, lon + cell_size, lon];  
        lat_points = [lat, lat, lat + cell_size, lat + cell_size];

        % Crear el polígono de la celda
        cell_polygon = geopolyshape(lat_points, lon_points);
    
        % Calcular distancia entre el punto y el centro de la celda
        dist = distance(latitud_origen, longitud_origen, lat, lon); 
        
        % Si es la celda más cercana encontrada hasta ahora, la guardamos
        if dist < min_distance
            min_distance = dist;
            closest_cell = u;
        end
    end

    % Asigna la celda más cercana a Data.celda
    if closest_cell ~= -1
        Data.celda(j, 1) = closest_cell;
    end
end

%}







 %% Guardar la estructura procesada de vuelta en la celda
    datasets{k} = Data;
  
end

% Extraer los datos procesados de nuevo a variables separadas
Data_ANC = datasets{1};
Data_CIC = datasets{2};



%% GUARDADO
save_filename = mat_filenameCIC;
save(save_filename, 'Data_CIC');
save_filename2 = mat_filenameANC ;
save(save_filename2, 'Data_ANC');
