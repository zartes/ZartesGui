function IVset=corregir4ramas(data)
%%%funcion para devolver las ivs corregidas a partir de datos tomados con 4
%%%ramas
    IVset.ibias_all=data(:,2)*1e-6;
    L=length(data(:,1));
    if mod(L-1,4) error('bad data format');end
    IVset.vout_all(1:(L-1)/4+1)=data(1:(L-1)/4+1,4)-data(1,4);
    IVset.vout_all((L-1)/4+1:3*(L-1)/4+1)=data((L-1)/4+1:3*(L-1)/4+1,4)-data(2*(L-1)/4+1,4);
    IVset.vout_all(3*(L-1)/4+1:L)=data(3*(L-1)/4+1:end,4)-data(end,4);
    
    %definimos las varias ramas
    IVset.ibias=IVset.ibias_all((L-1)/4+1:2*(L-1)/4+1);%%rama por defecto
    IVset.vout=IVset.vout_all((L-1)/4+1:2*(L-1)/4+1);%%
    
    IVset.ibias_P=IVset.ibias_all(1:(L-1)/4+1);%%rama P
    IVset.vout_P=IVset.vout_all(1:(L-1)/4+1);%%
    
    IVset.ibias_p=IVset.ibias_all((L-1)/4+1:2*(L-1)/4+1);%%rama p
    IVset.vout_p=IVset.vout_all((L-1)/4+1:2*(L-1)/4+1);%%
    
    IVset.ibias_N=-IVset.ibias_all(2*(L-1)/4+1:3*(L-1)/4+1);%%rama N
    IVset.vout_N=-IVset.vout_all(2*(L-1)/4+1:3*(L-1)/4+1);%%
    
    IVset.ibias_n=-IVset.ibias_all(3*(L-1)/4+1:L);%%rama n
    IVset.vout_n=-IVset.vout_all(3*(L-1)/4+1:L);%%