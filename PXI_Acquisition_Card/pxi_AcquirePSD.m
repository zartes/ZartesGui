function datos=pxi_AcquirePSD(pxi,varargin)
%%%Función para adquirir y salvar en fichero un espectro PSD con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

%default config para muestrear desde 1Hz a 100KHz.
opt.RL=2e5;%def: 2e5
opt.SR=2e5;%2e5
comment='test';
plotmode='V';%%%V: Voltage, I:current.

%%%configuracion subsampleo. Pasar como opcion
subsampling.bool=0;
subsampling.NpointsDec=100;
savebool=0;

for i=1:length(varargin)
    if isstruct(varargin{i}) opt=varargin{i};savebool=0;end
    if ischar(varargin{i}) comment=varargin{i};savebool=1;end%
end

pxi_Noise_Configure(pxi,opt);

if isfield(opt,'subsampling')
    subsampling.bool=opt.subsampling.bool;
    subsampling.NpointsDec=opt.subsampling.NpointsDec;
end
boolsubsampling=subsampling.bool;
NpointsDec=subsampling.NpointsDec;
%get(get(pxi,'horizontal'),'Actual_Sample_Rate')
%get(get(pxi,'horizontal'),'actual_record_length')

Options.TimeOut=5;
Options.channelList='1';

[data,~]=pxi_GetWaveForm(pxi,Options);
rg=skewness(data);

ix=0;
skewTHR=0.6;
while abs(rg(2))>skewTHR %%%%%Condición para filtrar lineas de base con pulsos! 0.004
    if ix>10, disp('Bucle sobre GetWaveForm en PSD ejecutado 10 veces');break;end
    [data,~]=pxi_GetWaveForm(pxi,Options);
    rg=skewness(data);
    ix=ix+1;
end
[psd,freq]=PSD(data);
%freq(end)
%size(freq), size(psd)

if(boolsubsampling)%%%subsampleo?
    %'subsampleo'
    if freq(1)==0, 
        logfmin=log10(freq(2));
    else
        logfmin=log10(freq(1));
    end%%%%Ojo, pq PSD hace fmin=0 siempre.?!
    logfmax=log10(freq(end));
    Ndec=logfmax-logfmin;
    %NpointsDec=200;%%%
    N=NpointsDec*Ndec;%%%numero de puntos.
    xx=logspace(logfmin,logfmax,N+1);%%%subsampleamos entre 1Hz y 100KHz.
    psd=interp1(freq,psd,xx);
    freq=xx;
end

medfiltWindow=1;%10;%%%<-Esto deberia ser configurable.

boolplot=1;
if isfield(opt,'boolplot')
    boolplot=opt.boolplot;
end
if isfield(opt,'plotmode')
    plotmode=opt.plotmode;
end
%%%data preparation
datos(:,1)=freq;
datos(:,2)=sqrt(psd);
if strcmp(plotmode,'I')&& isfield(opt,'circuit')
    datos(:,2)=V2I(datos(:,2),opt.circuit);
    str='ArHz';
    comment=strcat(comment,'_I_',str);
    ylimRange=[1e-11 1e-9];
else
    str='VrHz';
    comment=strcat(comment,'_V_',str);
    ylimRange=[1e-7 1e-5];
end
%%%

if(boolplot) %%%plot?
    auxhandle=findobj('name','PXI_PSD');
    if isempty(auxhandle) 
        auxhandle=figure('name','PXI_PSD'); 
    else figure(auxhandle);
    end
    subplot(2,1,1)
    plot(data(:,1),data(:,2));
    grid on
    subplot(2,1,2)
    %hold off
    Drhz=medfilt1(datos(:,2),medfiltWindow);
    loglog(freq(:),Drhz(:),'.-','linewidth',2)
    ylim(ylimRange),hold on
    ylabel(str);
    %semilogx(freq,10*log10(psd),'.-')
    grid on
    %%%
%     noisemodel=SnoiseModel(circuit,0.04);
%     noisemodel=NnoiseModel(circuit,0.18);
%     hold on
%     f=logspace(0,6,1000);
%     loglog(f,I2V(noisemodel,circuit),'r')
    %semilogx(logspace(0,6),20*log10(I2V(noisemodel,circuit)),'r')
end

if(savebool)
    file=strcat('PXI_noise_',comment,'.txt');
    save(file,'datos','-ascii');%salva los datos a fichero. Esto debería ser también configurable.
end