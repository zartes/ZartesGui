function TF = pxi_AcquireTF_updated(pxi)
%%%

    Options.TimeOut = 10;
    Options.channelList = '0,1';
    
    [ConfStructs, waveformInfo] = pxi_Init_ConfigStructs();
    ConfStructs.Vertical.channelList = '0,1';
    ConfStructs.Trigger.Type = 6;
    ConfStructs.Horizontal.RL = 2e6;
    pxi_ConfigureChannels(pxi, ConfStructs.Vertical);
    pxi_ConfigureHorizontal(pxi, ConfStructs.Horizontal);
    pxi_ConfigureTrigger(pxi, ConfStructs.Trigger)
    
   dsa = hp_init_updated(0);
%freq=logspace(0,5,81);

hp_WhiteNoise(dsa,100);
[data,WfmI]=pxi_GetWaveForm(pxi,Options);
txy=tfestimate(data(:,2),data(:,3));
n_avg=1;
for i=1:n_avg-1
    aux=tfestimate(data(:,2),data(:,3));
    txy=txy+aux;
end
txy=txy/n_avg;
txy=medfilt1(txy,40);
    if(1) %%%plot. señales.
        %[psd,freq]=PSD(data);
        subplot(2,1,1)
        plot(data(:,1),data(:,2));
        grid on
        subplot(2,1,2)
        %loglog(freq,psd,'.-')
        plot(data(:,1),data(:,3));
        grid on
    end
    
if(0)%%%Sine SWEEP
hp_Source_ON(dsa);
for i=1:length(freq)
    hp_sin_config(dsa,freq(i))
    pause(1);
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    
    if(1) %%%plot?
        %[psd,freq]=PSD(data);
        subplot(2,1,1)
        plot(data(:,1),data(:,2));
        grid on
        subplot(2,1,2)
        %loglog(freq,psd,'.-')
        plot(data(:,1),data(:,3));
        grid on
    end
    
    TFamp=range(data(:,3))/range(data(:,2)); %%approximate estimate of amplitude ratio
    TFang=acos(dot(data(:,2),data(:,3))/(norm(data(:,2))*norm(data(:,3))));%%%aprox estimate of phase difference
    Re(i)=TFamp*cos(TFang);
    Imag(i)=TFamp*sin(TFang);
    %TF(i)=TFamp*(cos(TFang)+1i*sin(TFang));
end
end
hp_Source_OFF(dsa);


RL=pxi.Horizontal.Actual_Record_Length;
SR=pxi.Horizontal.Actual_Sample_Rate;
DF=SR/RL;
%freq=DF:DF:SR/2;
freq=1:length(txy);
%TF=[freq' Re' Imag'];
%size(freq),size(txy),size(data)
%TF=[freq' real(txy) imag(txy)];
TF=data;
fclose(dsa);delete(dsa);