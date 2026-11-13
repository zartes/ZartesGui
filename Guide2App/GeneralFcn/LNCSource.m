classdef LNCSource
    % Class defining a Current Source.
    
    properties
        COM;
        baudrate;
        databits;
        parity;
        timeout;
        terminator;
        SourceCH;        
        LNCS_ILimit;        
        ObjHandle;
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            obj.COM = 'COM4';
            obj.baudrate = 57600;
            obj.databits = 7;
            obj.parity = 'even';
            obj.timeout = 2;
            obj.terminator = {'CR','CR'};
            obj.SourceCH = 2;
            
            obj.LNCS_ILimit = PhysicalMeasurement;
            obj.LNCS_ILimit.Value = 5000;
            obj.LNCS_ILimit.Units = 'uA';            
            
        end
        
        function [obj] = Initialize(obj)
            % Function that initialize the values of the source current
            obj = mag_init(obj);
            if obj.ObjHandle.Status == 'closed'
                obj.ObjHandle = [];
            end
        end
        
        function obj = SetILimit(obj,Ibvalue)
            
            obj.LNCS_ILimit.Value = Ibvalue.Value;
            obj.LNCS_ILimit.Units = Ibvalue.Units;
            
        end                
                
        function obj = SetIntensity(obj,Ibvalue)
            % Function to set I bias by LNCS (Low Noise Current Source)
            if strcmpi(Ivalue.Units, 'A')
                mag_setLNCSImag(obj,Ibvalue);
            else
                error('Ivalue units must be A');
            end            
        end
        
        function Ireal = Read_Current_Value_LNCS(obj)
            % Function to measure real Ibias by LNCS (Low Noise Current Source)
            
            Ireal = PhysicalMeasurement;
            Ireal.Value = mag_readLNCSImag(obj);
            Ireal.Units = 'uA';
        end
        
        function CurrentSource_Start(obj)
            % Function to connect LNCS (Low Noise Current Source)
            
            mag_ConnectLNCS(obj);
        end
        
        function CurrentSource_Stop(obj)
            % Function to disconnect LNCS (Low Noise Current Source)
            
            mag_DisconnectLNCS(obj);
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