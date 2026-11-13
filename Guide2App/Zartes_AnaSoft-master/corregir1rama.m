function IVset=corregir1rama(data)
%%%corregir datos de una rama de bajada positiva.
%%%ojo a si hay 2 o 4 columnas.
[~,j]=size(data);

if j==4
    IVset.ibias=data(:,2)*1e-6;
    ii=find(data(:,2)==0);
    if ~isempty(ii)
        IVset.vout=data(:,4)-data(ii(1),4);
    else
        IVset.vout=data(:,4);
    end
%     if data(1,2)==0
%         IVset.vout=data(:,4)-data(1,4);
%     elseif data(1,2)>0%%%
%         %ioffP=-0.140149074413429e-6;voffP=0.002882346043684;%%%
%         ioffP=0;voffP=0;
%         IVset.ibias=IVset.ibias-ioffP;%%%
%         IVset.vout=data(:,4)-voffP;%%%
%     elseif data(1,2)<0
%         %ioffN=0.088523295135426e-6;voffN=-0.323833329133775;%%%
%         ioffP=0;voffP=0;
%         IVset.ibias=IVset.ibias+ioffN;%%%
%         IVset.vout=data(:,4)+voffN;%%%
%     end
elseif j==2
        IVset.ibias=data(:,1)*1e-6;
    if data(1,1)==0
        IVset.vout=data(:,2)-data(1,2);
    else
        IVset.vout=data(:,2)-data(end,2);
    end
end