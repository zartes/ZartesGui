data = importdata('E:\RUN005\80.0mK\TF_112.4617uA.txt');

f = data(:,1);

clear data;
data(:,1) = f;

[file, path] = uigetfile;
uiopen([path file],1)
fig = gca;
rz = fig.Children.XData;
data(:,2) = rz;
im = fig.Children.YData;
data(:,3) = im;


save([path file(1:end-4) '.txt'],'data','-ascii','-tabs','-append');

%% Para el ruido
clear data;
[file, path] = uigetfile;
uiopen([path file],1);
fig = gca;
data(:,1) = fig.Children.XData;
data(:,2) = fig.Children.YData;
save([path file(1:end-4) '.txt'],'data','-ascii','-tabs','-append');