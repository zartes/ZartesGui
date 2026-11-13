function [posiciones, amplitudes] = peak_detector(signal, template, umbral, min_separacion)
% DETECTAR_EVENTOS - Matched filter para detección de pulsos
% Creado con Claude.
% Intento de convolucionar la ventana con un template. Pensado para pulsos
% rapidos.
%
% Inputs:
%   signal         - señal ruidosa (vector)
%   template       - forma esperada del pulso (vector)
%   umbral         - umbral de detección (0 a 1, fracción del máximo)
%   min_separacion - separación mínima entre picos (en muestras)
%
% Outputs:
%   posiciones  - índices de los picos detectados
%   amplitudes  - amplitud estimada de cada evento

%% 1. MATCHED FILTER (correlación cruzada normalizada)
template_norm = template - mean(template);        % quitar offset DC
signal_norm   = signal  - mean(signal);

% Correlación cruzada completa
mf = xcorr(signal_norm, template_norm);
%size(mf),size(template_norm)
% Quedarse solo con la parte causal (lags >= 0) y recortar al tamaño de signal
mf = mf(length(template_norm):end);
mf = mf(1:length(signal));                        % mismo largo que signal
% Normalizar entre 0 y 1 para aplicar umbral relativo
mf_norm = mf / max(abs(mf));

% 
%% 2. MATCHED FILTER con conv (mejor alineación)
template_inv = flipud(template_norm);
mf_raw       = conv(signal_norm, template_inv, 'full');
%mf_norm      = mf_raw / max(abs(mf_raw));
mf_raw  = mf_raw(length(template_norm) : length(signal_norm) + length(template_norm) - 1);
mf_norm = mf_raw / max(abs(mf_raw));
% 4. Corregir desfase: el pico de conv 'same' aparece en el centro del template
desfase = floor(length(template_norm) / 2);
mf_alineado = [zeros(desfase, 1); mf_norm(1:end-desfase)];

%% 2. DETECCIÓN DE PICOS
[~, posiciones] = findpeaks(mf_norm, ...
    'MinPeakHeight',    umbral, ...
    'MinPeakDistance',  min_separacion);

%% 3. ESTIMACIÓN DE AMPLITUD
% Ajuste por mínimos cuadrados: signal ? A * template en torno a cada pico
semi_ventana = floor(length(template) / 2);
amplitudes   = zeros(size(posiciones));

for i = 1:length(posiciones)
    p       = posiciones(i);
    idx_ini = max(1, p);
    idx_fin = min(length(signal), p + length(template) - 1);
    segmento = signal(idx_ini:idx_fin);
    
    % Quitar DC local del segmento
    segmento_norm = segmento - mean(segmento);

    % Recortar template al mismo tamaño
    n = min(length(segmento_norm), length(template_norm));
    seg = segmento_norm(1:n);
    tem = template_norm(1:n);

    % A = factor de escala: signal ? A * template
    amplitudes(i) = (tem(:)' * seg(:)) / (tem(:)' * tem(:));
end

boolplot=1;
if boolplot
%% 4. PLOT
figure;
subplot(3,1,1);
plot(signal); hold on;
title('Señal original');
ylabel('Amplitud'); xlabel('Muestras');

subplot(3,1,2);
plot(mf_norm); hold on;
%yline(umbral, 'r--', 'Umbral');
plot([1 length(mf_norm)], [umbral umbral], 'r--');
plot(posiciones, mf_norm(posiciones), 'rv', 'MarkerFaceColor', 'r');
title('Salida del Matched Filter (normalizada)');
ylabel('Correlación'); xlabel('Muestras');

subplot(3,1,3);
plot(signal); hold on;
yrange = ylim;
for i = 1:length(posiciones)
    %xline(posiciones(i), 'r--');
    plot([posiciones(i) posiciones(i)], yrange, 'r--');
    text(posiciones(i), amplitudes(i) * max(template), ...
        sprintf('A=%.2f', amplitudes(i)), ...
        'Color', 'r', 'FontSize', 8);
end
title('Eventos detectados');
ylabel('Amplitud'); xlabel('Muestras');
% Superponer template escalado encima de la señal
figure;%f2
plot(signal); hold on;
for i = 1:length(posiciones)
    p       = posiciones(i);
    idx_ini = max(1, p);
    idx_fin = min(length(signal), p + length(template_norm) - 1);
    n       = idx_fin - idx_ini + 1;
    
    % Template escalado + baseline local de la señal
    baseline = mean(signal(idx_ini:idx_fin));
    template_escalado = amplitudes(i) * template_norm(1:n) + baseline;
    
    plot(idx_ini:idx_fin, template_escalado, 'r', 'LineWidth', 2);
end
title('Señal + template escalado superpuesto');
end%if
end
