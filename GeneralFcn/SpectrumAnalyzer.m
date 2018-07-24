classdef SpectrumAnalyzer
    % Class defining a Spectrum Analyzer (Dynamic Signal Analyzer)
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        Header;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            obj.PrimaryAddress = 11;
            obj.BoardIndex = 1;
            obj.ID = 'HP3562A';
        end
        
        function [obj, status] = Initialize(obj)
            [obj, status] = hp_init_updated(obj);
            Calibration(obj)
        end
        
        function Calibration(obj)
            fprintf(obj.ObjHandle,'SNGC');%%%Calibramos el HP.
            h = waitbar(0,'Digital Signal Analyzer Calibrating...','WindowStyle','Modal','Name','ZarTES v1.0');
            tic;
            t = toc;
            while t < 20
                waitbar(t/20,h);
                t = toc;
            end
            close(h);
        end
        
        function obj = SineSweeptMode(obj,Amp)
            obj = hp_ss_config_updated(obj); % Measurement of Sine Sweept
            if nargin == 1
                str = strcat('SRLV 20mV');
            else
                str = strcat('SRLV ',' ',num2str(Amp),'mV'); % amplitud de excitación (mV!!)
            end
            fprintf(obj.ObjHandle,str);
        end
        
        function obj = FixedSine(obj,freq)
            hp_sin_config_updated(obj,freq);  % Fixed sine
        end
        
        function obj = NoiseMode(obj,Amp)  % Amplitud de excitación (mV!!)
            obj = hp_noise_config_updated(obj);
            hp_WhiteNoise_updated(obj,Amp);
        end
        
        function obj = SourceOn(obj)
            hp_Source_ON_updated(obj);
        end
        
        function obj = SourceOff(obj)
            hp_Source_OFF_updated(obj);
        end
        
        function LauchMeasurement(obj)
            fprintf(obj.ObjHandle,'STRT');             % Measurement is launched
            fprintf(obj.ObjHandle,'SMSD');             % Query measure finish?
            % Bucle waiting for the measurement
            while(~str2double(fscanf(obj.ObjHandle)))
                pause(10);
                fprintf(obj.ObjHandle,'SMSD');
                second(now)
            end
        end
        
        function [obj, datos] = Read(obj)
            [freq, data, header] = hp_read_updated(obj);
            datos = [freq' data'];
            obj.Header = header;
        end
        
        function Destructor(obj)
            try
                fclose(obj.ObjHandle); % Valid after fopen
            catch
            end
            delete(obj.ObjHandle);
            %             rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Analyzer_HP3562A\');
        end
    end
    
end