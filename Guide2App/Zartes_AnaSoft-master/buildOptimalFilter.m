function OF=buildOptimalFilter(MeanPulse,MeanNoise)
%%%Construccion del filtro optimo a partir del pulso y ruidos promedio.
%%%Suponemos MeanPulse=[time(:) V(:)]; y MeanNoise=[freqs(:) sqrt(PSD(:))];
oft=ifft(fft(MeanPulse(:,2))./abs(MeanNoise(:,2)).^2);
OF=double([MeanPulse(:,1) oft(:)]);
OF(:,2)=real(OF(:,2));
OF(:,2)=OF(:,2)/max(OF(:,2));
OF(:,2)=OF(:,2)-sum(OF(:,2))/length(OF(:,2));
