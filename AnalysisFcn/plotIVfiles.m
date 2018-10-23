function IVmeasure=plotIVfiles(Circuit,TbathArray)
%plot IVs at different Tbath from files.
%Falta implementar el uso de colores y markers diferentes.

Tbath=TbathArray;

[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\Feb2016\IVs\*','','Multiselect','on');

T=strcat(path,file);

if (iscell(T))
    %IVmeasure=zeros(1,length(T));
    data{:}=zeros(1,length(T));
for i=1:length(T),
    data{i}=importdata(T{i});
    %ibs{i}=data{i}(:,1);%%%
    %vouts{i}=data{i}(:,2);%%%
    IVmeasure(i)=BuildIVmeasureStruct(data{i},Tbath(i));%%%
    plotIVs(Circuit,IVmeasure(i)),hold on,
    
end
else
    data=importdata(T);
    %ibs=data(:,1);%%%
    %vouts=data(:,2);%%%
    IVmeasure=BuildIVmeasureStruct(data,Tbath);
    plotIVs(Circuit,IVmeasure)
end
grid on