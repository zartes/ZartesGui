function IVset=corregir1rama(data)
%%%corregir datos de una rama de bajada positiva.
%%%ojo a si hay 2 o 4 columnas.
[i,j]=size(data);

if j==4
    IVset.ibias=data(:,2)*1e-6;
    if data(1,2)==0
        IVset.vout=data(:,4)-data(1,4);
    else
        IVset.vout=data(:,4)-data(end,4);
    end
elseif j==2
        IVset.ibias=data(:,1)*1e-6;
    if data(1,1)==0
        IVset.vout=data(:,2)-data(1,2);
    else
        IVset.vout=data(:,2)-data(end,2);
    end
end