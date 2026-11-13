function PulseParameters = AnalizaPulseDir(dir,varargin)
%ANALIZAPULSO Summary of this function goes here
%   Detailed explanation goes here

%N=2000;
%basename='PXI_Pulso_*';
basename='pulso_*';
files=ls(strcat(dir,'\',basename));
N=length(files(:,1))
t0ini=0.1;
AMPthr=0.2;

ind=1:N;
if nargin==2
    ind=varargin{1};
end
%%%ordenar ficheros
for i=1:N
    xxx(i)=sscanf(files(i,:),'pulso_%d');
end
[ii,jj]=sort(xxx);
files=files(jj,:);
if N>1e6
    error('OJO: directorio grande');
end

%opt.RL=24576;%1e5;%2000;
%opt.SR=468750;%50e3;%100000;
xxx=regexp(files(1,:),'pulso_(?<index>\d*)_RL_(?<RL>\d*)_SR_(?<SR>\d*)','names');
opt.RL=str2num(xxx.RL);
opt.SR=str2num(xxx.SR);

i=1;
cd(dir)
for iii=ind;%1:N
try
    %file=strcat(dir,'pulso_',num2str(i));
    %pulso=importdata(strcat(dir,'\',files(i,:)));
    %file=strcat(dir,'\',files(iii,:));
    file=files(iii,:);
    pulso=readFloatPulse(file,opt);
    L=length(pulso(:,1));
    dc(i)=mean(pulso(1:L*t0ini/2,2));
    dc_std(i)=std(pulso(1:L*t0ini/2,2));
    area(i)=sum(medfilt1(pulso(:,2),10)-dc(i));
    amp(i)=max(medfilt1(pulso(:,2),10))-dc(i);
    %ind=find(pulso(:,2)-dc(i)<AMPthr);%%%seleccionamos un rango que no esté saturado para hacer el ajuste.
    %ind=find(pulso(:,1)<0.12 & pulso(:,1)>0.1);
    [v,t]=findpeaks(pulso(:,2),pulso(:,1),'minpeakprominence',0.05);
    %v=0;t=0;
    npeaks(i)=numel(v);
    ntimes(i).times=t;
    if(0)
        ind_fit=1:L;
        %p0=[0.01 0.001 1e-5];
        %fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
        p0=[0.1 0.001 1e-5 0.002];
        fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%simple
        %fhandle=@(p,x)p(1)*(1+p(5)*exp(-(x-p(4))/p(2))-(1+p(5))*exp(-(x-p(4))/p(3))).*heaviside(x-p(4));%%%step
        fit_pulso=lsqcurvefit(fhandle,p0,pulso(ind_fit,1),pulso(ind_fit,2)-dc(i));
        area_corrected(i)=sum(fhandle(fit_pulso,pulso(ind_fit,1)));
        tau_rise(i)=fit_pulso(3);
        tau_fall(i)=fit_pulso(2);
        A(i)=fit_pulso(1);
        t0(i)=fit_pulso(4);
    end
    if ~mod(i,10) i,end
    names{i}=file;
    index(i)=iii;
catch
        area(i)=0;
        dc(i)=0;
        dc_std(i)=0;
        amp(i)=0;
        npeaks(i)=0;
        ntimes(i).times=[];
        area_corrected(i)=0;
        tau_rise(i)=0;
        tau_fall(i)=0;
        A(i)=0;
        t0(i)=0;
        names{i}={};
        index(i)=0;
        'di error'
end
i=i+1;
end
cd ..
    PulseParameters.area=area;
    PulseParameters.dc=dc;
    PulseParameters.dc_std=dc_std;
    PulseParameters.amp=amp;
    PulseParameters.npeaks=npeaks;
    PulseParameters.ntimes=ntimes;
    PulseParameters.names=names;
    PulseParameters.index=index;
    %PulseParameters.fit_pulso=fit_pulso;
    %PulseParameters.area_corrected=area_corrected;
    %PulseParameters.A=A;
    %PulseParameters.tau_rise=tau_rise;
    %PulseParameters.tau_fall=tau_fall;
    %PulseParameters.t0=t0;