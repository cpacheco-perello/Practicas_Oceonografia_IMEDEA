function [yBestFit, bestModel] = EvaluaMejorPolinomio(X, Y, maxGrado)

% Inicializar el mejor error cuadrático medio
bestMSE = inf;
bestModel = [];
modelTypes = {'poly', 'exp1', 'logistic', 'log', 'power1'};  % Tipos de modelos a probar

for i = 1:length(modelTypes)
    modelType = modelTypes{i};
    
    if strcmp(modelType, 'poly')
        % Ajuste polinómico de diferentes grados
        for grado = 1:maxGrado
            modelo = fit(X, Y, sprintf('%s%d', modelType, grado));
            yFit = feval(modelo, X);  % Evaluar el modelo ajustado
            mse = mean((Y - yFit).^2);  % Calcular el MSE

            % Si el MSE es el mejor, guardamos este modelo
            if mse < bestMSE
                bestMSE = mse;
                bestModel = modelo;
            end
        end
    else
        % Ajustes para otros tipos de modelos
        try
            modelo = fit(X, Y, modelType);  % Ajuste usando el tipo de modelo
            yFit = feval(modelo, X);  % Evaluar el modelo ajustado
            mse = mean((Y - yFit).^2);  % Calcular el MSE

            % Si el MSE es el mejor, guardamos este modelo
            if mse < bestMSE
                bestMSE = mse;
                bestModel = modelo;
            end
        catch
            % Si no se puede ajustar el modelo, continuar con el siguiente tipo
            continue;
        end
    end
end

% Evaluar la mejor función encontrada
yBestFit = feval(bestModel, X);

end

