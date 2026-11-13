function PulseParameters=espectro(Npulsos,pxi,mag)
%Npulsos=200;
Ibias=round(mag_readImag_CH(mag,2));
area=zeros(1,Npulsos);dc=zeros(1,Npulsos);dc_std=zeros(1,Npulsos);
area2=zeros(1,Npulsos);
amp=zeros(1,Npulsos);area_corrected=zeros(1,Npulsos);%%%init._fit_pulso=zeros(1,Npulsos);
A=zeros(1,Npulsos);tau_fall=zeros(1,Npulsos);tau_rise=zeros(1,Npulsos);
for i=1:Npulsos
    try
    pulso=pxi_AcquirePulse(pxi,'prueba');
    
    L=length(pulso(:,1));
    %%%Extraccion parametros
    dc(i)=mean(pulso(1:L/10,2));
    dc_std(i)=std(pulso(1:L/10,2));
    area(i)=sum(pulso(:,2)-dc(i));
    area2(i)=sum(pulso(2*L/10-10:8*L/10,2)-dc(i));%%%Integro un rango menor de area.
    amp(i)=min(pulso(:,2))-dc(i);%%%max or min
    %fit
    %ind=find(pulso(:,2)-dc(i)<0.08);%%%si saturan.
    ind=1:L;
    trigger=0.1;
    t0=pulso(end,1)*trigger;%%%20%. Hay que fijarlo al Trigger Position.
    fhandle=@(p,x)p(1)*(exp(-(x-t0)/p(2))-exp(-(x-t0)/p(3))).*heaviside(x-t0);%%%ojo a t0.
    fit_pulso=lsqcurvefit(fhandle,[0.2 0.001 1e-5],pulso(ind,1),pulso(ind,2)-dc(i))
    %fit_pulso(i)=[0 0 0];
    area_corrected(i)=sum(fhandle(fit_pulso,pulso(:,1)));
        A(i)=fit_pulso(1);
        tau_fall(i)=fit_pulso(2);
        tau_rise(i)=fit_pulso(3);
    %%%%estructura
    PulseParameters.area=area;
    PulseParameters.area2=area2;
    PulseParameters.dc=dc;
    PulseParameters.dc_std=dc_std;
    PulseParameters.amp=amp;
    %PulseParameters.fit_pulso=fit_pulso;
    PulseParameters.area_corrected=area_corrected;
    PulseParameters.A=A;
    PulseParameters.tau_fall=tau_fall;
    PulseParameters.tau_rise=tau_rise;
    %%%salvo pulso
    file=strcat('Pulsos\pulso_',num2str(i));
    save(file,'pulso','-ascii');
    disp(['Pulse Number: ' num2str(i)])
    %subplot(2,1,2),hist(area,50)
    if ~mod(i,100) save('PulseParameters','PulseParameters');end %%salvo cada 100.
    %pause(1)
    catch
        area(i)=0;
        area2(i)=0;
        dc(i)=0;
        dc_std(i)=0;
        amp(i)=0;
        area_corrected(i)=0;
        A(i)=0;
        tau_fall(i)=0;
        tau_rise(i)=0;
        pxi_AbortAcquisition(pxi);
        Put_TES_toNormal_State_CH(mag,-500,2);
        mag_setImag_CH(mag,Ibias,2);
        mag_LoopResetCH(mag,2);
    end
end
hist(area,50)