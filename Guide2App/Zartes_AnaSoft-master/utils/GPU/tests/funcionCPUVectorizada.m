% Función CPU vectorizada
function resultado = funcionCPUVectorizada(n)
    tic;  % Inicia el cronómetro
    
    % Crea un vector en la CPU
    x = 1:n;
    
    % Vectoriza la operación (sin bucle for)
    resultado = sin(x) + cos(x.^2);
    
    tiempo = toc;  % Detiene el cronómetro
    fprintf('Tiempo de ejecución en CPU vectorizada: %f segundos\n', tiempo);
end