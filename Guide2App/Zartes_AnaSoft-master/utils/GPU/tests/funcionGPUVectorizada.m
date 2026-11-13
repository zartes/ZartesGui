% Función GPU vectorizada
function resultado = funcionGPUVectorizada(n)
    % Verifica que la GPU esté disponible
    if gpuDeviceCount == 0
        error('No se detectó ninguna GPU compatible con CUDA');
    end
    
    % Selecciona la GPU
    gpu = gpuDevice();
    
    tic;  % Inicia el cronómetro
    
    % Crea un vector en la GPU
    x = gpuArray(1:n);
    
    % Vectoriza la operación (sin bucle for)
    resultado_gpu = sin(x) + cos(x.^2);
    
    % Transfiere los resultados de vuelta a la CPU
    resultado = gather(resultado_gpu);
    
    tiempo = toc;  % Detiene el cronómetro
    fprintf('Tiempo de ejecución en GPU vectorizada: %f segundos\n', tiempo);
end