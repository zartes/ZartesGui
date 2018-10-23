classdef SpectrumAnalyzer
    % Class defining a Spectrum Analyzer (Dynamic Signal Analyzer)
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        Header;
        ObjHandle;
        Config;
    end
    
    methods
        function obj = Constructor(obj)
            obj.PrimaryAddress = 11;
            obj.BoardIndex = 0;
            obj.ID = 'HP3562A';
            obj.Config.SSine = {'AUTO 0';'SSIN';'LGSW';'RES 20P/DC';'SF 1Hz';'FRS 5Dec';...
                'SWUP';'SRLV 100mV';'C2AC 0';'FRQR';'VTRM';'VHZ';'NYQT'};
            obj.Config.FSine = {'LGRS';'FSIN 1Hz';'SRLV 20mV'};
            obj.Config.Noise1 = {'AUTO 0';'LGRS';'SF 10Hz';'FRS 4Dec';'PSUN';'VTRM';'VHZ';'STBL';...
                'AVG 5';'C2AC 1';'PSP2';'MGDB';'YASC'};
            obj.Config.Noise2 = {'LGRS';'RND';'SRLV 100mV'};
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
        
        function obj = SineSweeptMode(obj,Freq,Amp)             
            if nargin == 3
                obj.Config.SSine{8} = ['SRLV ' num2str(Amp) 'mV'];
            elseif nargin == 2
                obj.Config.SSine{5} = ['SF ' num2str(Freq) 'Hz'];                
            end
            for i = 1:length(obj.Config.SSine)
                fprintf(obj.ObjHandle,obj.Config.SSine{i});
            end
        end
        
        function obj = FixedSine(obj,Freq,Amp)            
            if nargin == 3
                obj.Config.SSine{3} = ['SRLV ' num2str(Amp) 'mV'];
            elseif nargin == 2
                obj.Config.SSine{2} = ['FSIN ' num2str(Freq) 'Hz'];                
            end
            for i = 1:length(obj.Config.FSine)
                fprintf(obj.ObjHandle,obj.Config.FSine{i});
            end
        end
        
        function obj = NoiseMode(obj,Freq)  % Amplitud de excitación (mV!!)            
            if nargin == 2
                obj.Config.Noise1{3} = ['SF ' num2str(Freq) 'Hz'];
            end
            for i = 1:length(obj.Config.Noise1)
                fprintf(obj.ObjHandle,obj.Config.Noise1{i});
            end
        end
        
        function obj = NoiseMode2(obj,Amp)  % Amplitud de excitación (mV!!)            
            if nargin == 2
                obj.Config.Noise2{3} = ['SRLV ' num2str(Amp) 'mV'];
            end
            for i = 1:length(obj.Config.Noise2)
                fprintf(obj.ObjHandle,obj.Config.Noise2{i});
            end
        end          
        
        function obj = SourceOn(obj)
            hp_Source_ON_updated(obj);
        end
        
        function obj = SourceOff(obj)
            hp_Source_OFF_updated(obj);
        end
        
        function LauchMeasurement(obj)
            h = waitbar(0,'Digital Signal Analyzer Reading...','WindowStyle','Modal','Name','ZarTES v1.0');            
            fprintf(obj.ObjHandle,'STRT');             % Measurement is launched
            fprintf(obj.ObjHandle,'SMSD');             % Query measure finish?
            % Bucle waiting for the measurement            
            while(~str2double(fscanf(obj.ObjHandle)))                
                pause(10);
                fprintf(obj.ObjHandle,'SMSD');
                second(now);
            end
            if ishandle(h)
                close(h);
            end
        end
        
        function [obj, datos] = Read(obj)
            LauchMeasurement(obj);
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