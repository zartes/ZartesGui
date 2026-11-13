function L=fitLcircuit(tfs,tfn,circuit)
%%%funcion para ajustar la L del circuito

p0=[65e-9 100e-3];
L=lsqcurvefit(@(x,y)fitLfcn(x,y,circuit),p0,tfs.f,imag(tfs.tf./tfn.tf));
