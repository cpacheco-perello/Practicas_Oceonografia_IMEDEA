clear all


%LONGIRUD EAST DEGREES 
long_min_bound = 350; 
long_max_bound = 45; 
lat_min_bound = 27; 
lat_max_bound = 50;  


folderPath ="C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat"; % Change to your folder path

% Get a list of all .zip files in the folder (change extension as needed)
files = dir(fullfile(folderPath, '*.nc')); % Modify to other file types if needed

% Loop over each file in the folder
for k = 1:length(files)
    % Get the current archive file name
    filename= fullfile(folderPath, files(k).name);
    
    % Display the current archive being processed
    disp(['Processing file: ', filename]);


    % Cargar los metadatos del archivo NetCDF
    MetaData = ncinfo(filename);
    
    % Inicializar una estructura para almacenar todas las variables
    Data = struct();
    Data_mediterraneo = struct(); % Nueva estructura para los datos filtrados
    % Cargar todas las variables del archivo NetCDF
    for i = 1:length(MetaData.Variables)
        var_name = MetaData.Variables(i).Name; % Obtener el nombre de la variable
        Data.(var_name) = ncread(filename, var_name); % Leer y almacenar la variable
    end
    
    % Verificar que las variables de latitud y longitud existan
    if isfield(Data, 'longitude_max') && isfield(Data, 'latitude_max')
        longitude= Data.longitude;
        latitude = Data.latitude;
    
        % Filtrar los puntos que están dentro de los límites ampliados (usando "degrees_east")
        in_mediterranean = ((longitude >= long_min_bound | (min(longitude)<= longitude & longitude <= long_max_bound)) & (latitude>= lat_min_bound & latitude <= lat_max_bound));
    
        % Obtener los índices de los puntos dentro del área filtrada
        indices_mediterraneo = find(in_mediterranean);
    
        % Mostrar la cantidad de puntos dentro de los nuevos límites
        fprintf('Número de puntos dentro del área Mediterráneo y países circundantes: %d\n', length(indices_mediterraneo));
    
        % Filtrar las variables para quedarse solo con los puntos dentro del área filtrada
    
        for var_name = fieldnames(Data)'
            var_name = var_name{1};
            % Filtrar la variable según los índices del Mediterráneo
            [rows, cols] = size(Data.(var_name));
            if cols<2
                Data_mediterraneo.(var_name) = Data.(var_name)(indices_mediterraneo, :);
            else
                % En el caso de variables 3D (lat, lon, tiempo u otras dimensiones)
                Data_mediterraneo.(var_name) = Data.(var_name)(:, indices_mediterraneo);
            end
        end
    
    else
        error('Las variables "longitude_max" o "latitude_max" no existen en el archivo NetCDF.');
    end

% Encontrar el índice de la primera aparición de '1' en el nombre del archivo
    nombre_archivo = files(k).name(11:end);
    index_of_1 = find(nombre_archivo == '1', 1);
    
    if ~isempty(index_of_1)
        % Extraer la parte antes del primer '1'
        filename_before_1 = nombre_archivo(1:index_of_1-1);
    else
        filename_before_1 = nombre_archivo; % Si no se encuentra el '1', usar el nombre completo
    end
    folder_guardado="C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo"
    % Definir el nuevo nombre para guardar los datos filtrados
    [~, name, ext] = fileparts(filename_before_1); % Obtener el nombre base sin extensión
    save_filename = fullfile( folder_guardado, ['Data',name, '_Mediterraneo.mat']);

    % Guardar los datos filtrados en un nuevo archivo con el nombre modificado
    save(save_filename, 'Data_mediterraneo');
    disp(['Saved filtered data to: ', save_filename]);
end
