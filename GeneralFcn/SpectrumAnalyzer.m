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
            % Function to generate the class with default values
            
            obj.PrimaryAddress = 11;
            obj.BoardIndex = 0;
            obj.ID = 'HP3562A';
            obj.Config.SSine = {'AUTO 0';'SSIN';'LGSW';'RES 20P/DC';'SF 1Hz';'FRS 5Dec';...
                'SWUP';'SRLV 100mV';'C2AC 0';'FRQR';'VTRM';'VHZ';'NYQT'};
            obj.Config.FSine = {'LGRS';'FSIN 1Hz';'SRLV 20mV'};
            obj.Config.WNoise = {'LGRS';'RND';'SRLV 100mV'};
            obj.Config.Noise = {'AUTO 0';'LGRS';'SF 10Hz';'FRS 4Dec';'PSUN';'VTRM';'VHZ';'STBL';...
                'AVG 5';'C2AC 1';'PSP2';'MGDB';'YASC'};
            
        end
        
        function [obj, status] = Initialize(obj)
            % Function that initialize the values of the Digital Signal
            % Analyzer
            
            [obj, status] = hp_init(obj);
            Calibration(obj)
        end
        
        function Calibration(obj)
            % Function to calibrate DSA
            
            fprintf(obj.ObjHandle,'SNGC');
            h = waitbar(0,'Digital Signal Analyzer Calibrating...','WindowStyle','Modal','Name','ZarTES v1.0');
            
            t = tic;
            while toc(t) < 25
                waitbar(toc(t)/25,h);
            end
            close(h);
        end
        
        function obj = SineSweeptMode(obj,Amp,Freq)
            % DSA Configuration for Z(w) acquisition by Sweept Sine input
            
            if nargin == 3
                obj.Config.SSine{5} = ['SF ' num2str(Freq) 'Hz'];                   
                obj.Config.SSine{8} = ['SRLV ' num2str(Amp) 'mV'];
            elseif nargin == 2
                obj.Config.SSine{8} = ['SRLV ' num2str(Amp) 'mV'];
            end
            for i = 1:length(obj.Config.SSine)
                fprintf(obj.ObjHandle,obj.Config.SSine{i});
            end
        end
        
        function obj = FixedSine(obj,Amp,Freq)             
            % DSA Configuration for Z(w) acquisition by Fixed Sine input
            
            if nargin == 3
                obj.Config.SSine{3} = ['SRLV ' num2str(Amp) 'mV'];
                obj.Config.SSine{2} = ['FSIN ' num2str(Freq) 'Hz'];
            elseif nargin == 2
                obj.Config.SSine{3} = ['SRLV ' num2str(Amp) 'mV'];
            end
            for i = 1:length(obj.Config.FSine)
                fprintf(obj.ObjHandle,obj.Config.FSine{i});
            end
        end
        
        function obj = WhiteNoise(obj,Amp)
            % DSA Configuration for Z(w) acquisition by white noise input
                        
            if nargin == 2
                obj.Config.WNoise{3} = ['SRLV ' num2str(Amp) 'mV'];
            end
            for i = 1:length(obj.Config.WNoise)
                fprintf(obj.ObjHandle,obj.Config.WNoise{i});
            end
        end     
        
        
        function obj = NoiseMode(obj,Freq)     
            % DSA Configuration for noise acquisition
            
            if nargin == 2
                obj.Config.Noise{3} = ['SF ' num2str(Freq) 'Hz'];
            end
            for i = 1:length(obj.Config.Noise)
                fprintf(obj.ObjHandle,obj.Config.Noise{i});
            end
        end                     
        
        function obj = SourceOn(obj)
            % Function to turn on the input source
            
            hp_Source_ON(obj);
        end
        
        function obj = SourceOff(obj)
            % Function to turn off the input source
            hp_Source_OFF(obj);
        end
        
        function LauchMeasurement(obj)
            % Function for starting acquisition 
            
            h = waitbar(0,'Digital Signal Analyzer Reading...','WindowStyle','Modal','Name','ZarTES v1.0');            
            fprintf(obj.ObjHandle,'STRT');             % Measurement is launched
            fprintf(obj.ObjHandle,'SMSD');             % Query measure finish?
            % Bucle waiting for the measurement            
            i = 1;
            while(~str2double(fscanf(obj.ObjHandle)))  
                if ishandle(h)
                    waitbar(i/50,h);
                end
                pause(1);
                fprintf(obj.ObjHandle,'SMSD');                
                i = mod(i+1,50);
            end
            if ishandle(h)
                close(h);
            end
        end
        
        function [obj, datos] = Read(obj)
            % Function for read DSA output
            
            LauchMeasurement(obj);
            [freq, data, header] = hp_read(obj);
            datos = [freq' data'];
            obj.Header = header;
        end
        
        function Destructor(obj)
            % Function to delete the object class
            try
                fclose(obj.ObjHandle); % Valid after fopen
            catch
            end
            delete(obj.ObjHandle);
        end
    end
    
end