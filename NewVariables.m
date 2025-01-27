close all;
clear all;
folderPath = 'C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo';
filenameAnticiclonica = 'Data_twosat_Anticyclonic_long__Mediterraneo.mat';
filenameCiclonica = 'Data_twosat_Cyclonic_long__Mediterraneo.mat';

mat_filenameANC = fullfile(folderPath, filenameAnticiclonica);
mat_filenameCIC = fullfile(folderPath, filenameCiclonica);

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

·
%% VIDA MAXIMA




    % Guardar la estructura procesada de vuelta en la celda
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
