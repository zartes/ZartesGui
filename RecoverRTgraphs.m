d = dir('Ch*.dat');

for k = 1:length(d)
    clear data;
    try
        fid = fopen(d(k).name, 'r');
        DisplayStr = d(k).name(1:end-4);
        DisplayStr(DisplayStr == '_') = ' ';
        j = 1;
        while true
            tline = fgetl(fid);
            try
                data(j,:) = str2num(tline);
                j = j+1;
            catch
            end
            
            if ~ischar(tline), break, end
            %     disp(tline)
        end
        fclose(fid);
        s = strtok(d(k).name,'Ch');
        
        Channel = [3 5 7 9 11 13 15 17];
        Channel_indx = str2double(s(1))+1;
        data(:,Channel(Channel_indx));
        figure;
        plot(data(:,Channel(Channel_indx)-1),data(:,Channel(Channel_indx)),...
            '*','DisplayName',DisplayStr);
        xlabel('Temperature (K)');
        ylabel('Resistence (ohm)');
        title(DisplayStr);
        set(gca,'FontUnits','Normalized');
        grid on;
        hgsave(d(k).name(1:end-4));
    catch
        figure;
        plot(data(:,1),data(:,2),'*','DisplayName',DisplayStr);
        xlabel('Temperature (K)');
        ylabel('Resistence (ohm)');
        title(DisplayStr);
        grid on;
        set(gca,'FontUnits','Normalized');
        hgsave(d(k).name(1:end-4));
    end
    
end
