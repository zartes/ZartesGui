function ShowZFits(ZTESDATA,Tbath)
%%%%Función para ejecutar desde el directorio común de estructuras para
%%%%visualizar las Z(w) y ruidos.

bdir=pwd;

dir=ZTESDATA.datadir;
cd(dir);
%ssn=ZTESDATA.session; %%%%!!!!Ojo, a la definición de 'sesion' o 'session'.
%aux=load(ssn,'TFS');


%FitZfiles(ZTESDATA.IVset,ZTESDATA.circuit,ZTESDATA.TES,aux.TFS);

% str=dir('*mK');
% for i=1:length(str)
%     if strfind(str(i).name,Tbath) & str(i).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
% end

FitZset(ZTESDATA.IVset,ZTESDATA.circuit,ZTESDATA.TES,ZTESDATA.TFS,Tbath);%%%%Hay que poner boolShow=1 dentro de la funcion.

cd(bdir);