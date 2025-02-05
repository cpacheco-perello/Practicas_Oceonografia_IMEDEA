%% Geographical bounds (expanded Mediterranean region)
long_min_bound = -10;
long_max_bound = 45;
lat_min_bound = 27;
lat_max_bound = 50;
% Read the shapefile for country boundaries
% Read the shapefile for country boundaries

countries = readgeotable("C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS" + ...
    "\\ne_10m_admin_0_countries\ne_10m_admin_0_countries.shp");

%% CONTAR CARACT POR CELDA 

Data=Data_CIC;


track = unique(Data.track);  % Obtiene los valores únicos de 'track'
Cuenta_celdas = zeros(1, length(cells));  % Inicializa el contador de celdas (ajusta según el número máximo de celdas)
vidamedia= zeros(1, length(cells)); 

for j = 1:length(track)
    % Acceder al valor de track en la posición j
    track_value = track(j);
    
    % Encontrar los índices donde el 'track' es igual al valor actual
    idx = find(Data.track == track_value);
    
    % Filtrar las filas donde el valor de 'track' es igual al valor actual
    Celdas = Data.celda(idx);
    Lifetime= Data.lifetime(idx);% Extrae las celdas correspondientes
    num_celda = Celdas(1);  % Asume que la primera celda es la que quieres contar (ajustar según lo que necesites)
    vida_max=max(Lifetime);
    if num_celda ~= 0
    % Incrementar el contador para esa celda
      Cuenta_celdas(num_celda) = Cuenta_celdas(num_celda) + 1;
      vidamedia(num_celda)=vidamedia(num_celda)+vida_max;
    end
end
 for i = 1:length(Cuenta_celdas)
    % Asegurarse de que Cuenta_celdas(i) no sea cero
    if Cuenta_celdas(i) ~= 0
        vidamedia(i) = vidamedia(i) / Cuenta_celdas(i);  % Calcula la vida media
    else
        vidamedia(i) = 0;  % Si no hay celdas asociadas, la vida media será 0
    end
end

titulo="ANTICICLONICOS";
TituloColorbar="Nacimiento";


Dato_arepresenter= vidamedia;
minC = min(Dato_arepresenter);  % Encuentra el valor mínimo
maxC = max(Dato_arepresenter);  % Encuentra el valor máximo
cmap =(cmocean('thermal'));  % Genera un mapa de colores con 80 colores

% Crea la figura
figure;

% Crear el mapa global usando worldmap
ax = worldmap([lat_min_bound lat_max_bound], [long_min_bound long_max_bound]);
setm(ax, 'Frame', 'on', 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on');

% Mostrar los límites de los países
geoshow(countries, 'FaceColor', [0.3 0.4 0.3], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1);


% Suponiendo que 'cells' contiene la información de las celdas (lon, lat)
% Tomamos los valores de lat y lon para la primera celda
for j = 1:length(cells)
    value = Dato_arepresenter(j);
    
    index = round((value - minC) / (maxC - minC) * (size(cmap, 1) - 1)) + 1;
    
    % Extrae el color correspondiente
    color = cmap(index, :);
    lon = cells(j).Longitude;
    lat = cells(j).Latitude;
    
    % Rellenar la celda con el color determinado
     h = fillm(lat, lon, 'FaceColor', color, 'EdgeColor', 'none');  % Dibuja la celda
    set(h, 'FaceAlpha', 0.8);  % Establece la opacidad a 0.8
    
end

% Título y etiquetas
title(titulo);


% Mostrar la barra de colores
colormap(cmap);
clim([minC,maxC]);  
cb = colorbar; 

cb.Title.String=(TituloColorbar);
cb.Title.FontSize = 12;