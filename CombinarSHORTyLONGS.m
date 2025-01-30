close all;
clear all;
folderPath = 'C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS\DATOS\twosat\Mediterraneo';
filenameAnticiclonicaL = 'Data_twosat_Anticyclonic_long__Mediterraneo.mat';
filenameAnticiclonicaS = 'Data_twosat_Anticyclonic_short__Mediterraneo.mat';
filenameCiclonicaL = 'Data_twosat_Cyclonic_long__Mediterraneo.mat';
filenameCiclonicaS = 'Data_twosat_Cyclonic_short__Mediterraneo.mat';

mat_filenameANCL = fullfile(folderPath, filenameAnticiclonicaL);
mat_filenameCICL = fullfile(folderPath, filenameCiclonicaL);
mat_filenameANCS = fullfile(folderPath, filenameAnticiclonicaS);
mat_filenameCICS = fullfile(folderPath, filenameCiclonicaS);
%% Load the .mat files
Data_CICS = load(mat_filenameCICS);
Data_ANCS = load(mat_filenameANCS);
Data_CICL = load(mat_filenameCICL);
Data_ANCL = load(mat_filenameANCL);
% Get the field names of the structs

% Access the first variable inside the struct
Data_CICL = Data_CICL.Data_CIC;
Data_ANCL = Data_ANCL.Data_ANC;
Data_CICS = Data_CICS.Data_mediterraneo;
Data_ANCS = Data_ANCS.Data_mediterraneo;

Data_CICS.track=Data_CICS.track+10000000;
Data_ANCS.track=Data_ANCS.track+10000000;






% Combinar las estructuras concatenando los valores de los campos
combinedStruct = struct();
fields = fieldnames(Data_CICS); % Asumimos que struct1 y struct2 tienen los mismos campos

for i = 1:numel(fields)
    field = fields{i};
    [rows, cols] = size(Data_CICL.(field )) ;
    if cols<2% Obtener el nombre del campo
        combinedStruct.(field) = [Data_CICL .(field); Data_CICS.(field)];
    else 
        combinedStruct.(field) = [Data_CICL .(field), Data_CICS.(field)];
    end% Concatenar los valores del campo
end

combinedStructA = struct();
fieldsA = fieldnames(Data_ANCS); % Asumimos que struct1 y struct2 tienen los mismos campos

for i = 1:numel(fieldsA)
    field = fields{i};
    [rows, cols] = size(Data_ANCS.(field )) ;
    if cols<2% Obtener el nombre del campo
        combinedStructA.(field) = [Data_ANCL .(field); Data_ANCS.(field)];
    else 
        combinedStructA.(field) = [Data_ANCL .(field),Data_ANCS.(field)];
    end% Concatenar los valores del campo
end