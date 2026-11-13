function L=fitLcircuit(tfs,tfn,circuit)
%%%funcion para ajustar la L del circuito

L=lsqcurvefit(@(x,y)fitLfcn(x,y,circuit),100e-9,tfs.f,imag(tfs.tf./tfn.tf));
