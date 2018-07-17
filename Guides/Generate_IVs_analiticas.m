function Generate_IVs_analiticas

f = @(p,x) x.^2./(p(1)*(x-p(2)));
f1 = @(p,x) p*x;
datay(Ibs > 60) = f([800 60],Ibs(Ibs > 60));
datay(Ibs <= 60) = f1(0.0087,Ibs(Ibs <= 60));
figure,plot(Ibs,datay)