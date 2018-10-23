function [data,out]=loadppms()
%carga de golpe ficheros tomados en el PPMS con Header (32 lineas)
%se salta la primera columna, por lo que T=col3, R1=col6, R2=col8.
%se accede a los datos como data{i}(:,:)

%[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\*.dat','','Multiselect','on')
[file,path]=uigetfile('\\155.210.93.138\Usuarios\Nico\Datos\*.dat','','Multiselect','on'); %9T

T=strcat(path,file);
if(iscell(T))
    data=zeros(1,length(T));
for i=1:length(T),
    data{i}=csvread(T{i},32,1);
    saux=strcat('t',num2str(i),'=data{',num2str(i),'}(:,3);');evalin('caller',saux);
    saux=strcat('r',num2str(i),'1','=data{',num2str(i),'}(:,20);');evalin('caller',saux);
    saux=strcat('r',num2str(i),'2','=data{',num2str(i),'}(:,21);');evalin('caller',saux);
    saux=strcat('r',num2str(i),'3','=data{',num2str(i),'}(:,22);');evalin('caller',saux);
    saux=strcat('r',num2str(i),'4','=data{',num2str(i),'}(:,23);');evalin('caller',saux);
end
else
    data=csvread(T,32,1);
    out.T=data(:,3);
    out.R1=data(:,19);
    out.R2=data(:,20);
    out.R3=data(:,21);
    out.R4=data(:,22)
    
    %error.pq?
    %saux=strcat('t','=data(:,3);');evalin('caller',saux);
    %saux=strcat('r1','=data(:,6);')%,evalin('caller',saux)
    %saux=strcat('r2','=data(:,8);'),evalin('caller',saux)
end
