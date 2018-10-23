function TF = importTF(varargin)

TF = [];
if nargin == 1
    [file, path] = uigetfile([varargin{1} '*'],'Pick Transfer Functions','Multiselect','off');
else
    [file, path] = uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Mayo2016\Z(w)\*','','Multiselect','off');
end
if iscell(file)||ischar(file)
    T = strcat(path, file);
else
    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
    return;
end
% [file,path] = uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Mayo2016\Z(w)\*','','Multiselect','on');

if ~isnumeric(file)
%     T = strcat(path,file);
    if (iscell(T))
        data = {[]};
        TF = {[]};
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
            TF{i}.file = T{i};
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
        TF.file = T;
    end
else
    warndlg('No file selected','ZarTES v1.0')
    TF.tf = [];
    TF.re = [];
    TF.im = [];
    TF.f = [];
    TF.file = [];
end
