function Tc=fitUsadel(p,dAu)%ds
%Creo una función a partir de 'usadelTc.m' con la forma adecuada para usar
%lsqcurvefit. 
%Permite ajustar datos experimentales para sacar los valores
%de d_oro, 't' y 'Tc0' que mejor ajustan.
%bool=0;
p=real(p);
%Tc=martinis(ds,p(1),p(2),p(3),bool,p(4)); %añado p(4)=RRRs,usado si bool=1.
%Tc=usadelTc(ds,p(1),p(2),p(3));
Tc=usadelTc(40,dAu,p(1),p(2));