classdef OptFilter
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        MeanNoise
        MeanPulse
        OF
        fhandle
        p0
        I0
        oft = [];
        tini = 0.1;
        optfraction = 0.055;
        boolfit = 0;
        wfilt = 1;
        fit_range
        oftrange        
        polarity
        filtopt

    end

    methods        

        function obj = buildOptimalFilter(obj)
            %%%Construccion del filtro optimo a partir del pulso y ruidos promedio.
            %%%Suponemos MeanPulse=[time(:) V(:)]; y MeanNoise=[freqs(:) sqrt(PSD(:))];

            obj.oft = ifft(fft(obj.MeanPulse(:,2))./abs(obj.MeanNoise(:,2)).^2);
            obj.OF = double([obj.MeanPulse(:,1) obj.oft(:)]);
            obj.OF(:,2) = real(obj.OF(:,2));
            obj.OF(:,2) = obj.OF(:,2)/max(obj.OF(:,2));
            obj.OF(:,2) = obj.OF(:,2)-sum(obj.OF(:,2))/length(obj.OF(:,2));
        end

        function obj = buildMeanPSDfromFITS(obj,file,indNoise)

            import matlab.io.*
            DataUnit=2;%!default 2.
            info=fitsinfo(file);
            N=info.BinaryTable(DataUnit-1).Rows;
            fptr=fits.openFile(file);
            fits.movAbsHDU(fptr,DataUnit);%!
            SR=str2double(fits.readKey(fptr,'SR'));
            RL=str2double(fits.readKey(fptr,'RL'));
            fits.closeFile(fptr);

            if nargin==3
                index=indNoise;%por si hacemos un filtrado previo de los baselines.
            else
                index=1:N;
            end
            aux=zeros(RL,1);
            window=[];
            %window=hamming(RL);
            for i=index
                noise=readFITSpulse(file,i,DataUnit);%%%asumimos baselines en Dataunit=2
                %%%noise contiene ya time y data
                %[psd,freqs]=PSD(noise,1);%%%lo hacemos 2-sided
                [psd,freqs]=periodogram(noise(:,2),window,RL,SR,'two-sided');
                %size(aux),size(psd)
                aux=aux(:)+psd(:);
            end
            Mpsd=aux/length(index);
            obj.MeanNoise(:,1)=freqs;
            obj.MeanNoise(:,2)=sqrt(abs(Mpsd));%devolver directamente sqrt(Mpsd)?
        end

        function obj = buildMeanPulsefromFITS(obj, file,indPulse)
            import matlab.io.*
            DataUnit = 2;%!
            info = fitsinfo(file);
            N = info.BinaryTable(DataUnit-1).Rows;
            fptr = fits.openFile(file);
            fits.movAbsHDU(fptr,DataUnit);
            % SR = str2double(fits.readKey(fptr,'SR'));
            RL = str2double(fits.readKey(fptr,'RL'));
            fits.closeFile(fptr);

            if nargin == 3
                index = indPulse;%por si hacemos un filtrado previo de los pulsos.
            else
                index = 1:N;
            end
            L = length(index);
            aux = zeros(RL,1);
            % window=[];
            %window=hamming(RL);
            for i = index
                auxpulse = readFITSpulse(file,i,DataUnit);%%%asumimos baselines en Dataunit=2

                aux = aux(:)+auxpulse(:,2);%
            end
            obj.MeanPulse = double([auxpulse(:,1) aux(:)/L]);
            obj.fhandle = @(p,x)p*interp1(obj.MeanPulse(:,1),obj.MeanPulse(:,2),x);
            obj.p0 = 0.200;

        end

        function plotOFfilter(obj)
            
            figure,
            plot(obj.OF)
            
        end

        
    end
end