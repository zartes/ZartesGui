function SimPuls=SimPulsosBasic(varargin)
%%%%%Funcion para simular pulsos con ruido y evaluar estimadores de
%%%%%energia.
opt=[];
if nargin==1
    opt=varargin{1};
end
%%%%%Parametros iniciales
if isfield(opt,'Nsims')
    Nsims=opt.Nsims;
else
    Nsims=1000;
end
if isfield(opt,'sigma')
    Sigma0=opt.sigma;
else
    Sigma0=1e-3;%%%sigma para ruido gaussiano.
end
if isfield(opt,'tini')
    t0ini=opt.tini;
else
    t0ini=0.1;%%%posición del trigger (valor entre 0 y 1)
end
if isfield(opt,'MeanPulse')
    T=opt.MeanPulse(:,1);
    Tmin=ToptCalcMeanPulse(opt.MeanPulse);%ojo tini=0.1;
    topt=t0ini+Tmin/T(end);%expresado como tanto por 1.
else
    T=[0:1e-6:20e-3];%%%Vector inicial de tiempos.
    %%%parametros del pulso:[A tau1 tau2 t0 dc]
    p0=[0.5 2e-3 2e-5 2e-3 0];%%%parametros de forma del pulso.
    if isfield(opt,'p0') p0=opt.p0;end
    Tmin=ToptCalc(p0);
    topt=t0ini+Tmin/T(end);%0.065;%0.128;%%%posicion final para integracion optima
    %%%topt expresado también como fracción entre 0 y 1.
    %%%fracción para integrar resolucion optima. 
    %%%Minimo en Res para sigma=0.01 tau1=2e-3 tau2=2e-4 -> 0.35
end
if mod(length(T),2) T=T(1:end-1);end
L=length(T);
Lopt=(topt-t0ini)*L;

if isfield(opt,'MeanPulse')
    V0=opt.MeanPulse(:,2);
else
    pulsH=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4))+p(5);
    V0=pulsH(p0,T);
    V0(isnan(V0))=0;
end

%%%Monte Carlo for Amplitud
Kafhandle=BuildMnKaHandle;
Earray=MonteCarloSimPDF(Kafhandle);
%%%
for i=1:length(Earray)%Nsims
    if isfield(opt,'psd')
        [noise,times]=iPSD(opt.psd,opt.freqs);
        pnoise=interp1(times,noise,T);
        V=V0+pnoise;
    else
        %size(V0),size(randn(1,L))
        V=V0(:)+Sigma0*randn(L,1);%%%%pulso con ruido gaussiano.
        V=V*Earray(i)*max(V0)/5898.75;%%%
        %jitter simulation
        jdt=2;%jitter step
        if rand>0.33
            V(1:end-jdt)=V(1+jdt:end);%movido pulso jdt izda
        else
            V(1+jdt:end)=V(1:end-jdt);%movido pulso jdt dcha
        end
    end
    pulso=double([T(:) V(:)]);
    dc(i)=mean(pulso(1:L*t0ini/2,2));
    dc_std(i)=std(pulso(1:L*t0ini/2,2));
    areaRaw(i)=sum(medfilt1(pulso(:,2),1))-dc(i)*L;%%%
    pulsTrunc=pulso(L*t0ini:L*topt,2);
    areaOpt(i)=sum(medfilt1(pulsTrunc,1),1)-dc(i)*Lopt;
    amp(i)=max(medfilt1(pulso(:,2),10))-dc(i);
    %fit_pulso=lsqcurvefit(pulsH,p00,T(L*t0ini:end),V(L*t0ini:end));
    %fitDC(i)=fit_pulso(5);
    %A(i)=fit_pulso(1);
    %fitArea(i)=sum(pulsH(fit_pulso,T(L*t0ini:end))-fit_pulso(5));
    if ~mod(i,10) i,end
end
SimPuls.dc=dc;
SimPuls.dc_std=dc_std;
SimPuls.areaRaw=areaRaw;
SimPuls.areaOpt=areaOpt;
SimPuls.amp=amp;
%SimPuls.fit.dc=fitDC;
%SimPuls.fit.A=A;
%SimPuls.fit.area=fitArea;