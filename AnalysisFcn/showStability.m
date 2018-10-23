function showStability(TES,Circuitparam)
%mostrar superficie de estabilidad para un TES.
step=1e-4;
trange=0.95:step:1.02;irange=0:step:0.02;%%%1.5
[X,Y]=meshgrid(trange,irange);
TES=SetOP(X*TES.Tc,Y*TES.Ic,TES);%llama a FtesTI.
stab=StabilityCheck(TES,Circuitparam);%
%figure

hold off %%%Este hold controla la representacion en el plano I-T.
%axis ij square off
%contourf(X,Y,FtesTI(X,Y));%evitar llamada a FtesTI.
%contourf(X*TES.Tc,Y*TES.Ic,TES.R0/TES.Rn);
h(1)=image(trange*TES.Tc,irange*TES.Ic,TES.R0/TES.Rn);
hold on
%colormap gray
%colormap(flipud(colormap))
%alpha(0.5)

%freezeColors %funciona para distintos axes en la misma fig pero no para el
%mismo axes.
%contourf(Trange,Irange,~stab.stab);
stc=2*(~stab.stab)+(~stab.expo&stab.stab);

%contourf(X*TES.Tc,Y*TES.Ic,stc);
h(2)=image(trange*TES.Tc,irange*TES.Ic,stc);
%alpha(0.3)

%contourcmap('cool')
%colormap cool

maps.a=gray(10);
maps.a=flipud(maps.a);
%maps.b=cool(64);
maps.b=[[0 1 0];[1 1 0];[1 0 0]];
multicmap(h,maps);
alpha(0.5)
set(h(2),'alphadata',0.5*(~stab.stab|~stab.expo));
set(gca,'Ydir','Normal')
grid on