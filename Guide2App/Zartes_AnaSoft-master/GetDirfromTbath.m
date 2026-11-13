function Tdir=GetDirfromTbath(Tbath)
%%%%función para devolver el directorio correspondiente a una Tbath dada.
%%%Encapsulo código que tenía en varias funciones y lo mejoro un poco.

str=dir('*mK');

if isnumeric(Tbath)
    if Tbath<0.1 Tbath=Tbath*1e3;end %%%Asumimos que si Tbath es <0.1 la estamos pasando en Kelvin y la pasamos a mK.
    Tbathstr=num2str(Tbath);%%%(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
elseif ischar(Tbath)
    Tbathstr=Tbath;
end
for i=1:length(str)
    %str(i)
    if strfind(str(i).name,Tbathstr) & str(i).isdir, break;end
end
Tdir=str(i).name;