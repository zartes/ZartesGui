% Función GPU vectorizada en MATLAB 2024
function resultado = funcionGPU2024(n)
    % Verificar disponibilidad de GPU
    if gpuDeviceCount == 0
        error('No se detectó ninguna GPU compatible');
    end
    
    % Seleccionar GPU y resetearla para liberar memoria
    g = gpuDevice();
    reset(g);
    
    % Medición de tiempo más precisa
    t = tic;
    
    % Creación y cálculo en GPU (sintaxis similar)
    x = gpuArray(1:n);
    resultado_gpu = sin(x) + cos(x.^2);
    
    % Usar waitForDevice para asegurar que todos los cálculos GPU han terminado
    wait(g);
    
    % Transferir resultados a CPU
    resultado = gather(resultado_gpu);
    
    tiempo = toc(t);
    fprintf('Tiempo en GPU (MATLAB 2024): %f segundos\n', tiempo);
    
    % Información más detallada sobre la GPU
    fprintf('GPU: %s, CUDA: %s\n', g.Name, g.ComputeCapability);
    fprintf('Memoria usada: %.2f/%.2f GB\n', (g.TotalMemory-g.AvailableMemory)/1e9, g.TotalMemory/1e9);
end