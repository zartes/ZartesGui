
clear all

namedir = pwd;
[namefile,namedir] = uigetfile('*.fits','Select Pulse FIT file',namedir);
filename = [namedir namefile];
addpath('.\HandleLibrary\')
addpath('.\jsonlab-2.0\')

tic
OF = OptFilter;
pulsos = PullPulse;
pulsos = pulsos.CharacterizeRawPull(filename);
pulsos = pulsos.DetIndexes;

OF = OF.buildMeanPSDfromFITS(filename,pulsos.indNoise);
OF = OF.buildMeanPulsefromFITS(filename,pulsos.indKaGood);
OF = OF.buildOptimalFilter;

pulsos = pulsos.OFT(OF.OF);

pulsos = pulsos.RemoveOutliers_DC(3);

pulsos = pulsos.ClusteringData;



pulsos = pulsos.RemoveOutliers_DC(3,1);
[eVres, Nbin] = pulsos.ResolutionEstimation(1,3);
[eVres, Nbin] = pulsos.ResolutionEstimation(2,3);


t = toc;
disp(t)
figure,plot(pulsos.dc,'.'), hold on, plot(pulsos.indKaGood,pulsos.dc(pulsos.indKaGood),'.r')




% Parámetros iniciales
datos_crudos = obj.OFT_Energy(:);
inds = obj.indKaNaN;
inds(isnan(inds)) = [];
datos_Ka = obj.OFT_Energy(inds);
% datos_Ka = obj.dc(obj.indKaNaN); % Aseguramos que sea un vector columna
IQR_Factor = 3; % Factor habitual para outliers

% Array para guardar las etiquetas: NaN = Outlier, 1 = Grupo 1, 2 = Grupo 2
etiquetas_finales = NaN(size(datos_crudos)); 

%% FASE 1: Detección de Outliers Globales
% Calculamos cuartiles y límites globales
Q_global = median(datos_Ka); 
% IQR_global = Q_global(2) - Q_global(1);
limite_inf_global = Q_global - (IQR_Factor * iqr(datos_Ka));
limite_sup_global = Q_global + (IQR_Factor * iqr(datos_Ka));

% Identificamos qué datos son VÁLIDOS (no outliers globales)
mascara_validos_global = (datos_crudos >= limite_inf_global) & (datos_crudos <= limite_sup_global);
indices_validos = find(mascara_validos_global);
etiquetas_finales(indices_validos) = 1;


datos_validos = datos_crudos(indices_validos);


datos_dc_validos = obj.dc(indices_validos);
%% FASE 2: Clusterización de los datos buenos (K = 2)
% Aplicamos kmeans solo a los datos que superaron el primer filtro

eva = evalclusters(datos_dc_validos', 'kmeans', 'Silhouette', 'KList', 1:10);
[idx_clusters, ~] = kmeans(datos_dc_validos', 2);

% Asignamos las etiquetas de los clusters a sus posiciones originales
etiquetas_finales(indices_validos) = idx_clusters;


%% FASE 3: Detección de Outliers Locales (por subgrupo)
% Recorremos cada uno de los 2 clusters que acabamos de crear
for k = 1:2
    % 1. Encontrar los índices globales que pertenecen al cluster k
    indices_cluster_k = find(etiquetas_finales == k);
    datos_cluster_k = datos_crudos(indices_cluster_k);
    
    % 2. Calcular límites estadísticos locales (específicos de este cluster)
    Q_local = median(datos_cluster_k);
    % IQR_local = Q_local(2) - Q_local(1);
    limite_inf_local = Q_local - (IQR_Factor * iqr(datos_cluster_k));
    limite_sup_local = Q_local + (IQR_Factor * iqr(datos_cluster_k));
    
    % 3. Identificar qué datos DE ESTE CLUSTER son outliers
    mascara_outliers_locales = (datos_cluster_k < limite_inf_local) | (datos_cluster_k > limite_sup_local);
    
    % 4. Mapear a los índices originales y marcarlos como NaN (Outliers)
    indices_outliers_locales = indices_cluster_k(mascara_outliers_locales);
    etiquetas_finales(indices_outliers_locales) = NaN;
end

%% RESULTADO FINAL: Actualizar el objeto original
obj.clusIndx = etiquetas_finales;

% Si también necesitas actualizar otra variable como indicabas en tu código original:
obj.indKaNaN = NaN(size(datos_crudos));
obj.indKaNaN(~isnan(etiquetas_finales)) = 1; % Por ejemplo, marcar con 1 los que son válidos finales