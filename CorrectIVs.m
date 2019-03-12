
filePath = 'C:\Users\Athena\Documents\GitHub\Zartes_2018\Zartes\Guis\Medidas_Juan_Lunes04032019_SinCampo\IVs\';
% filePath = 'C:\Users\Athena\Documents\GitHub\Zartes_2018\Zartes\Guis\Medidas_Juan_Lunes04032019_Campo800\IVs\';
d = dir([filePath '*.txt']);

for i = 1:length(d)
    data = importdata([filePath d(i).name]);
    if data(end,2) == 0
        data(:,4) = data(:,4)-data(end,4);
        save([filePath 'CorrectedIV\' d(i).name],'data','-ascii');
        continue;
    else
        h = figure;hx = axes;plot(hx,data(:,2),data(:,4));
        hd = get(hx,'Children');
        data(:,2) = get(hd,'XData');
        data(:,4) = get(hd,'YData');
        ind = find(isnan(data(:,4)));
        data(ind,:) = [];
        p = polyfit(data(end-3:end,2),data(end-3:end,4),1);
        y = polyval(p,0);
        data(end+1,2) = 0;
        data(end,4) = y;
        data(:,4) = data(:,4)-data(end,4);
        save([filePath 'CorrectedIV\' d(i).name],'data','-ascii');
        close(h);
    end
    
end
    