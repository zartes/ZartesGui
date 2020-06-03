
% Transformar figs en txt (NOISE HP)
path = 'G:\Unidades compartidas\ZARTES\Mayo\test Nico';
d = dir([path filesep '*NoiseHP*.fig']);
for i = 1:length(d)
    open(['G:\Unidades compartidas\ZARTES\Mayo\test Nico' filesep d(i).name]);
    fg = gcf;
    chaxe = get(fg,'Children');
    lineschaxe = get(chaxe(1),'Children');
    datos(:,1) = lineschaxe.XData;
    datos(:,2) = lineschaxe.YData;
    % figure,loglog(datos(:,1),datos(:,2))
    save([path filesep 'Conversion' filesep d(i).name(1:end-4) '.txt'],'datos','-ascii')
    close(fg);
end

% Transformar figs en txt (TF HP)
path = 'G:\Unidades compartidas\ZARTES\Mayo\test Nico';

S = load([path filesep 'TFN_HP_Ib500uA_150mK_B700uA.txt'], '-ascii');
d = dir([path filesep '*TF*HP*.fig']);
for i = 1:length(d)
    clear datos;
    open(['G:\Unidades compartidas\ZARTES\Mayo\test Nico' filesep d(i).name]);
    fg = gcf;
    chaxe = get(fg,'Children');
    lineschaxe = get(chaxe(1),'Children');
    datos(:,1) = S(:,1);
    datos(:,2) = lineschaxe(1).XData;
    datos(:,3) = lineschaxe(1).YData;    
    save([path filesep 'Conversion' filesep d(i).name(1:end-4) '.txt'],'datos','-ascii')
    close(fg);
end

% Transformar figs en txt (NOISE PXI)
path = 'G:\Unidades compartidas\ZARTES\Mayo\test Nico';
d = dir([path filesep '*NoisePXI*.fig']);
for i = 1:length(d)
    clear datos;
    open(['G:\Unidades compartidas\ZARTES\Mayo\test Nico' filesep d(i).name]);
    fg = gcf;
    chaxe = get(fg,'Children');
    lineschaxe = get(chaxe(1),'Children');
    datos(:,1) = lineschaxe.XData;
    datos(:,2) = lineschaxe.YData;
    % figure,loglog(datos(:,1),datos(:,2))
    save([path filesep 'Conversion' filesep d(i).name(1:end-4) '.txt'],'datos','-ascii')
    close(fg);
end

% Transformar figs en txt (TF PXI)
path = 'G:\Unidades compartidas\ZARTES\Mayo\test Nico';

S = load([path filesep 'PXI_TF_88.5728uA.txt'], '-ascii');
d = dir([path filesep '*TF*PXI*.fig']);
for i = 1:length(d)
    clear datos;
    open(['G:\Unidades compartidas\ZARTES\Mayo\test Nico' filesep d(i).name]);
    fg = gcf;
    chaxe = get(fg,'Children');
    lineschaxe = get(chaxe(2),'Children');
    datos(:,1) = S(:,1);
    datos(:,2) = lineschaxe.XData;
    datos(:,3) = lineschaxe.YData;  
    % figure,loglog(datos(:,1),datos(:,2))
    save([path filesep 'Conversion' filesep d(i).name(1:end-4) '.txt'],'datos','-ascii')
    close(fg);
end