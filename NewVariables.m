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
cell_size = 1; 
celda_result = zeros(size(Data.track)); % Crear un array para almacenar resultados
track = unique(Data.track);
h = waitbar(0, 'Procesando...');
% Iterar sobre cada valor único en 'track'
for j = 1:length(track)
    % Acceder al valor de track en la posición j
    track_value = track(j);
% Paso 1: Obtener el valor mínimo de la columna 'track'

    % Encontrar los índices donde Data.track coincide con track_value
    idx = find(Data.track == track_value);

    % Paso 2: Filtrar las filas donde el valor de 'track' es igual al valor mínimo
    latitud= (Data.latitude(idx));
    latitud_origen=latitud(1);

    longitud= (Data.longitude(idx));
    longitud_origen=longitud(1);

    % Obtener las coordenadas del punto a verificar

    % Crear un punto en las coordenadas de latitud y longitud
    point = geopointshape(latitud_origen, longitud_origen);

    for u = 1:length(cells)
        lon=cells(u).Longitude;
        lat=cells(u).Latitude;
        % Crear los vértices del cuadrado (polígono de la celda)
        

    % Crear el polígono de la celda usando geoshape
        cell_polygon = geopolyshape(lat,  lon);
    
        % Verificar si el punto está dentro del polígono de la celda
        
        if isinterior(cell_polygon, point)
            celda_result(idx, 1)=u;
            break
        end 
    end

    
    %pause(0); 
    waitbar(j/length(track), h, sprintf('Progreso: %.2f%%', (j/length(track))*100));

end
Data.celda = celda_result;


    

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
