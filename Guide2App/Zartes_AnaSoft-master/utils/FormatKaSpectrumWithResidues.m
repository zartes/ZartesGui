function options=FormatKaSpectrumWithResidues(Data)
%%%instrucciones para formatear figura de espectro con Residuos.
%%%VERSION EN utils github
%%%Ojo, script tambien en "F:\ATHENA\medidas\BlueFors\2025\Enero\CH1\Pulsos\miercoles"
% if nargin ==0
    nbins=40;
    finecal=1.0;
    xlimits=[5875 5910];%Original [5875 5910];
    title_str='default %Rn';
    p0=[120 3];
    plot_format='errorbar';% 'bar' or 'errorbar'.
    options.nbins=nbins;
    options.finecal=finecal;
    options.xlimits=xlimits;
    options.p0=p0;
    options.title=title_str;
    options.plot_format=plot_format;
    % warning('Need Ecal and Data as input');
    % return
% elseif nargin==1
%         options=varargin{1};
% end
% if ~isfield(options,'Data')
%     error('Need Ecal and Data');
% end

%%%OPTIONS
MnKaHandle=BuildMnKaHandle;
nbins=options.nbins;
finecal=options.finecal;
xlimits=options.xlimits;
title_str=options.title;
p0=options.p0;
EauxCal=options.Ecal;
Pauxdata=options.Data;

figure('windowstyle','docked')
subplot(2,1,1);
SpPosition=[0.1300    0.2641    0.7750    0.6609];
%set(haux,'Position',SpPosition);
%pintar histograma

%need to select data in indx and calibrate.
%Pauxdata=Pch1_30mK_12Rn.OFT_Energy(indx(indx2));
%Pauxdata=Pch2L08_15Rn.OFT_Energy(indx);
%EauxCal=NL_Ecal;
calibrated_spectrum=EauxCal(Pauxdata);
%hist(calibrated_spectrum,nbins);
if isfield(options,'Ebins')
    Ebins=options.Ebins;
else
    Ebins=[5870:0.5:5915];
end
%[h,x]=hist(calibrated_spectrum,nbins);
[h,x]=hist(finecal*calibrated_spectrum,Ebins);
%x=finecal*x;%%%!manual recalibration!

%indx=[1:14 16:40];%%%debug
if isfield(options,'exclude')
    exclude=options.exclude;
else
    exclude=[];
end
kk=[];
for i=1:numel(exclude) kk=[kk find(x==exclude(i))];end
index=setdiff(1:numel(x),kk)-1;
index=index(index>0);
%x(index)
%index=find(x>exclude(1) & x<exclude(2));
[p,~,residual,~,~,~,jacob]=lsqcurvefit(MnKaHandle,p0,x(index),h(index));
ci= nlparci(p,residual,'jacobian',jacob);
err=(ci(2,2)-ci(2,1))/2;%sigma.
switch options.plot_format
    case 'errorbar'
        errorbar(x,h,sqrt(h),'-s','linestyle',':','linewidth',1,'marker','.','markersize',24)
    case 'bar'
        bar(x,h,'linewidth',1,'facecolor',[1 1 1]*0.8);
end
%formateo espectro
xlim(xlimits);
set(gca,'fontsize',15)
set(gca,'xtick',[]);%quitamos ejeX
grid on
hold on
%superponer fit o linea. 
E=[5840:0.1:5950];
line_color=[0.6353 0.0784 0.1843];
plot(E,MnKaHandle(p,E),'color',line_color,'linewidth',3);
plot(E,MnKaHandle([p(1) 0.01],E),'--','color','k','linewidth',2);
plot(exclude,h(kk),'xr','markersize',10)
res=sprintf('%2.1f',p(2));
sigma=sprintf('%2.1f',err);
legend({' K_{\alpha} data',[' ',res,[' \pm' char(32)],sigma,' eV Fit']});%modify text
title(title_str)%modify text
%legend({'K_{\alpha} data','3 eV Fit'});%modify text
%%%plot residuos
%pause(1)
subplot(2,1,2);
RsPosition=[0.1300    0.1100    0.7750    0.1270];
set(gca,'Position',RsPosition);
%define.[h,x]=hist(calibrated_spectrum,nbins)
stem(x,h-MnKaHandle(p,x),'.-')
xlim(xlimits);
set(gca,'fontsize',15)
xlabel('E(eV)')
R=sqrt(sum((h-MnKaHandle(p,x)).^2));
%legend(strcat('R: ',num2str(R,4)));
legend(['R: ',' ',sprintf('%4.2f',R)]);
legend boxoff
subplot(2,1,1)
set(gca,'Position',SpPosition);