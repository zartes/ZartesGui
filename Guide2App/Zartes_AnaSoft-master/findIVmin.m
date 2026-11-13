function ind=findIVmin(IVset)
%%%Función que busca el Punto de una curva IV en que se alcanza el mínimo.
%%%Este punto corersponde con el punto en que L0=1 y Ztes=inf. 
for i=1:length(IVset)
[m,mi]=min(abs(diff(IVset{i}.vout)));
ind(i)=mi(1);
end