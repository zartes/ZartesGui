function TF = importTF()

[file,path] = uigetfile('G:\Unidades de equipo\ZARTES\DATA\*','','Multiselect','on');

T = strcat(path,file);

if (iscell(T))
    for i = 1:length(T)
        data{i} = importdata(T{i});
        tf = data{i}(:,2)+1i*data{i}(:,3);
        re = data{i}(:,2);
        im = data{i}(:,3);
        f = data{i}(:,1);
        TF{i}.tf = tf;
        TF{i}.re = re;
        TF{i}.im = im;
        TF{i}.f = f;
    end
else
    
    data = importdata(T);
    tf = data(:,2)+1i*data(:,3);
    re = data(:,2);
    im = data(:,3);
    f = data(:,1);
    TF.tf = tf;
    TF.re = re;
    TF.im = im;
    TF.f = f;
    
end