%% Geographical bounds (expanded Mediterranean region)
long_min_bound = -10;
long_max_bound = 45;
lat_min_bound = 27;
lat_max_bound = 50;

% Cargar shapefile del Mediterráneo (o el contorno del océano en general)
shapefile_path = fullfile("C:", "Users", "pache", "Documents", "AAB--Practicas", "IMEDEA", ...
                          "CODIGO - DATOS", "Recursos", "Contornos Oceanos", "lme.shp");
% Read the shapefile for country boundaries
countries = readgeotable("C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS" + ...
    "\\ne_10m_admin_0_countries\ne_10m_admin_0_countries.shp");
% Cargar el shapefile
S = readgeotable(shapefile_path);  % Asegúrate de que la ruta sea correcta
S_mediterranean = S(S.lme_name == "Mediterranean Sea", :);

mediterranean_geometry = S_mediterranean.Shape;
% Crear una figura
figure;

% Crear el mapa global usando worldmap
ax = worldmap([lat_min_bound lat_max_bound], [long_min_bound long_max_bound]);
setm(ax, 'Frame', 'on', 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on');

    % Show country borders
geoshow(countries, 'FaceColor', [0.3 0.4 0.3], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1,'Parent', ax);
% Mostrar el contorno de los océanos
geoshow(ax, S, 'DisplayType', 'line');

% Título y etiquetas
title('Contorno del Mar Mediterráneo');
xlabel('Longitud');
ylabel('Latitud');



long_min_bound = -9;
long_max_bound = 40;
lat_min_bound = 30;
lat_max_bound = 47;
cell_size = 1;

% Crear las coordenadas de latitud y longitud para las celdas
longitudes = long_min_bound:cell_size:long_max_bound;
latitudes = lat_min_bound:cell_size:lat_max_bound;

cells = geoshape.empty;


% Iterar sobre las celdas y mirar si estan en el mediterraneo

for lat = latitudes
    for lon = longitudes
        % Crear las coordenadas de los vértices de la celda
        lon_points = [lon, lon + cell_size, lon + cell_size, lon];  % Coordenadas de longitud
        lat_points = [lat, lat, lat + cell_size, lat + cell_size];  % Coordenadas de latitud
        
        % Obtener el centro de la celda
        center_lon = lon + cell_size / 2;
        center_lat = lat + cell_size / 2;
        % Verificar si el centro de la celda está dentro del Mediterráneo
        point_center = geopointshape(center_lat, center_lon);
        is_inside_center = isinterior(mediterranean_geometry, point_center);
        
        % Verificar si al menos uno de los cuatro vértices está dentro del Mediterráneo
        points_vertices = geopointshape(lat_points, lon_points);
        is_inside_vertices = any(isinterior(mediterranean_geometry, points_vertices));
        
        % Si el centro o al menos un vértice está dentro del Mediterráneo, agregar la celda
        if is_inside_center || is_inside_vertices  % El punto está dentro o sobre el borde
            % Asegurarse de cerrar el polígono de la celda
            lon_points = [lon_points, lon_points(1)];
            lat_points = [lat_points, lat_points(1)];
            
            % Crear el polígono de la celda
            cell_polygon = geoshape(lat_points, lon_points);
            
            % Agregar la celda al contenedor de celdas
            cells = [cells; cell_polygon];
        end
    end
end

% Mostrar las celdas en el mapa
geoshow(cells);

