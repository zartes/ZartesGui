function [psd,freq]=PSD(data)
%%%calcula el espectrum power de una serie temporal data conteniendo tiempo
%%%y valores

t=data(:,1);
x=data(:,2);
SF=1./mean(diff(t))%
N=length(x);
ft=fft(x);ft=ft(1:N/2+1);
psd=abs(ft).^2/SF/N;
psd(2:end-1)=2*psd(2:end-1);
freq=0:SF/N:SF/2;
