function varargout=FitKaData(Pdata,Kaindex)
%%%funcion para crear, calibrar y ajustar datos de pulsos Ka.
%Asume que Pdata tiene ya campo OFT_Energy y que se han seleccionado
%en Kaindex los índices de los datos Kalfa.
nbins=50;
Ka1=5887.65;%maximo Ka1.
Ka2=5898.4;%maximo Ka2.
KData=Pdata.OFT_Energy;%(Kaindex);
%correct timeline fluctuations
% Twindow=20;
% MM=movingMean(KData,Twindow);
% KData=KData-MM+MM(1);
% figure('windowstyle','docked')
% plot(Pdata.timestamp(Kaindex),Pdata.OFT_Energy(Kaindex),'.');
% hold on
% plot(Pdata.timestamp(Kaindex),KData,'.');
% plot(Pdata.timestamp(Kaindex),MM,'.r');
%
%%%Intento de fraccionar en rodajas temporales. DTminutos es el ancho
%%%de cada rodaja. Pero si es demasiado pequeño, el fit gauss2 no encuentra
%%%las 2 poblaciones y si es muy grande, tampoco mejora nada. Para
%%%deshabilitarlo basta poner un número mayor que la duracion del run.
t0=Pdata.timestamp(Kaindex(1));
tend=Pdata.timestamp(Kaindex(end));
DTminutes=600;%20;%delta T en minutos.
DT=DTminutes/1440;
N=ceil((tend-t0)/DT);
t1=t0;t2=t1+DT;
EData=[];
for i=1:N
    i
    indT=find(Pdata.timestamp>t1 & Pdata.timestamp<t2);
    ind=intersect(indT,Kaindex);
    %max(ind)
    [h,x]=hist(KData(ind),nbins);
    hist(KData(ind),nbins),pause(0.2)
    try
        f = fit(x(:),h(:),'gauss2');
    catch
        continue;
    end
    Ka_cal=polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
    %calibrate data
    EData=[EData polyval(Ka_cal,KData(ind))];
    t1=t2;t2=t1+DT;
end
if nargout==1
    varargout{1}=Ka_cal;
end
%Twindow=1;
%MM=movingMean(EData,Twindow);
%EData=EData-MM+5894.4;%
[h,x]=hist(EData,nbins);
hist(EData,nbins)
MnKaHandle=BuildMnKaHandle;
p0=[100 5];
p=lsqcurvefit(MnKaHandle,p0,x(:),h(:));
%plot
figure('windowstyle','docked')
%hist(polyval(Ka_cal,Pdata.OFT_Energy(Kaindex)),nbins);
hist(EData,nbins);
grid on
hold
E=5875:0.1:5910;%poster Emanuele 5870:5915;
plot(E,MnKaHandle(p,E),'r','linewidth',3)
xlim([5875 5910]);
set(gca,'fontsize',15)
xlabel('E(eV)')
str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),' eV');
legend({'K_\alpha data' str},'Location','northwest')