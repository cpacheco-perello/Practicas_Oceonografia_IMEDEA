
% Paso 1: Obtener el valor mínimo de la columna 'track'
min_value = min(Data_mediterraneo.track);
idx=find(Data_mediterraneo.track == min_value);
% Paso 2: Filtrar las filas donde el valor de 'track' es igual al valor mínimo
latitud= (Data_mediterraneo.latitude(idx));
latitud_origen=latitud(1);

longitud= (Data_mediterraneo.longitude(idx));
longitud_origen=longitud(1);

% Crear un punto en las coordenadas de latitud y longitud
point = geopointshape(latitud_origen, longitud_origen);

% Definir el tamaño de la celda en grados
cell_size = 0.5; 

% Crear los vértices del cuadrado (polígono de la celda)
lon_points = [longitud_origen, longitud_origen + cell_size, longitud_origen + cell_size, longitud_origen];  % Coordenadas de longitud
lat_points = [latitud_origen, latitud_origen, latitud_origen + cell_size, latitud_origen + cell_size];  % Coordenadas de latitud

% Crear el polígono de la celda usando geoshape
cell_polygon = geoshape(lat_points, lon_points);

% Ahora, necesitas verificar si el punto está dentro del polígono.
% Para esto, puedes usar la función 'inpolygon' en lugar de 'isinterior'.

% Obtener las coordenadas del punto a verificar
x_point = longitud_origen; % Coordenada x (longitud) del punto
y_point = latitud_origen;  % Coordenada y (latitud) del punto

% Verificar si el punto está dentro del polígono de la celda
in_cell = inpolygon(x_point, y_point, lon_points, lat_points);


% Mostrar el resultado
if in_cell
    disp('El punto está dentro del polígono de la celda.');
else
    disp('El punto NO está dentro del polígono de la celda.');
end
