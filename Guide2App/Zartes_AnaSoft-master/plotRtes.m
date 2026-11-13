function plotRtes()
Trange=[0:1e-3:1.5e-1];Irange=[0:1e-7:1e-3];
[X,Y]=meshgrid(Trange,Irange);
mesh(X,Y,RtesTI(X,Y))