function TF=importTF(varargin)

if nargin==0
    x=dir('TFS.txt');
    if length(x)
        T='TFS.txt';
    else
        [file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Mayo2016\Z(w)\*','','Multiselect','on');
        T=strcat(path,file);
    end
elseif isempty(varargin{1})
        [file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Mayo2016\Z(w)\*','','Multiselect','on');
        T=strcat(path,file);
else
    T=varargin{1};
end

if (iscell(T))
    for i=1:length(T),
        data{i}=importdata(T{i});
        tf=data{i}(:,2)+1i*data{i}(:,3);
        re=data{i}(:,2);
        im=data{i}(:,3);
        f=data{i}(:,1);
        TF{i}.tf=tf;
        TF{i}.re=re;
        TF{i}.im=im;
        TF{i}.f=f;
    end
else
    
        data=importdata(T);
    tf=data(:,2)+1i*data(:,3);
    re=data(:,2);
    im=data(:,3);
    f=data(:,1);
    TF.tf=tf;
    TF.re=re;
    TF.im=im;
    TF.f=f;
    
end
