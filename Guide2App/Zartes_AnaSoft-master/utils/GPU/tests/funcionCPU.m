% Función sin paralelizar (CPU)
function resultado = funcionCPU(n)
    resultado = zeros(n, 1);
    tic;  % Inicia el cronómetro
    for i = 1:n
        resultado(i) = sin(i) + cos(i^2);
    end
    tiempo = toc;  % Detiene el cronómetro
    fprintf('Tiempo de ejecución en CPU: %f segundos\n', tiempo);
end