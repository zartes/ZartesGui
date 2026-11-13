function pulsefit=Fit_Pulse_Files(list)
%%%fit script. p=[A t1 t2 t0]

for i=1:length(list) 
    aux=importdata(list(i,:));
    %plot(aux(:,1),aux(:,2)); 
    pulsos75mK(i,:,:)=aux;
end
bsFilt = designfilt('bandstopfir','FilterOrder',100,'CutoffFrequency1',2e6,'CutoffFrequency2',3e6, 'SampleRate',1e7);
for i=1:length(list)
    xdata=pulsos75mK(i,1:300,1);
    ydata=medfilt1(pulsos75mK(i,1:300,2)-median(pulsos75mK(i,end-100:end,2)),1);
    ydata=filter(bsFilt,ydata);
    plot(xdata,ydata);hold on;
    p=lsqcurvefit(@Fit_V_Delta,[-2.5 5e-6 0.8e-7 14e-6],xdata,ydata,[-inf 0 0 0 ],[0 inf inf inf]);
    pulsefit.A(i)=p(1); pulsefit.t1(i)=p(2);pulsefit.t2(i)=p(3); pulsefit.t0(i)=p(4);
end