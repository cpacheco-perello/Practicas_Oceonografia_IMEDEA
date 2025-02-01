%% Geographical bounds (expanded Mediterranean region)
long_min_bound = -10;
long_max_bound = 45;
lat_min_bound = 27;
lat_max_bound = 50;

% Read the shapefile for country boundaries
countries = readgeotable("C:\Users\pache\Documents\AAB--Practicas\IMEDEA\CODIGO - DATOS" + ...
    "\\ne_10m_admin_0_countries\ne_10m_admin_0_countries.shp");

ax = worldmap([lat_min_bound lat_max_bound], [long_min_bound long_max_bound]);
    setm(ax, 'Frame', 'on', 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on');

    % Show country borders
    geoshow(countries, 'FaceColor', [0.3 0.4 0.3], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1,'Parent', ax);