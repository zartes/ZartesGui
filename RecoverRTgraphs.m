d = dir('Ch*.dat');
figure;
hold on;
for k = 1:length(d)
    clear data;
    try
        fid = fopen(d(k).name, 'r');
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
        
        plot(data(:,Channel(Channel_indx)-1),data(:,Channel(Channel_indx)),'DisplayName',d(k).name);
    catch
    end
    xlabel('T (K)');
    ylabel('R (ohm)');
end
