function Rtes = RtesTI(Ttes,Ites)
%parametros del TES
%Rn=20e-3; %resistencia en estado normal.
%Tc=0.1;%DT=0.0001; %Tc del TES
%Ic=1e-3;%DI=5e-6; %corriente crítica 

%cambio unidades.
Rn=2;Tc=1;Ic=1; %

Dr=0.1;%0.01
%Rtes=Rn./(1+exp(-(sqrt((Ttes/Tc).^2+(Ites/Ic).^2).^4-1)./Dr));

%model2
r=sqrt((Ttes/Tc).^2+(Ites/Ic).^2);
r1=1-Dr;
r2=1+Dr;
Rtes=Rn*((r-r1)/(r2-r1)).^1;
Rtes(find(r<=r1))=0;
Rtes(find(r>=r2))=Rn;


%sqrt((DT/Tc).^2+(DI/Ic).^2)

%para visualizar la superficie:
%Trange=[0:1e-3:1.5e-1];Irange=[0:1e-7:1e-4];
%[X,Y]=meshgrid(Trange,Irange);
%mesh(X,Y,RtesTI(X,Y))