function pulso=readFloatPulse(file,varargin)
%%%funcion para leer un pulso de fichero binario en formato float en
%%%columna simple.

if nargin==1
    version='2cols'
else
    version='1col'
    opt=varargin{1};
end

switch version
    case '2cols'
        fid=fopen(file);
        L=length(fread(fid,[1 inf],'float'))/2;
        frewind(fid);
        data=fread(fid,[L 2],'float');
        fclose(fid);
        pulso=data;%%%time axis is coded in col1.
    case '1col'
        fid=fopen(file);
        data=fread(fid,opt.RL,'float');
        fclose(fid);
        L=0:1/opt.SR:((opt.RL-1)/opt.SR);
        %size(data),size(L),
        pulso=[L(:) data(:)]; 
end