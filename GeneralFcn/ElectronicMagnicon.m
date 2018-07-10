classdef ElectronicMagnicon
    % Class of Electronic Magnicon Setup
    
    properties
        COM;
        baudrate;
        databits;
        parity;
        timeout;
        terminator;
        SourceCH;
        Rf;
        PulseAmp;
        RL;        
        PulseDT;
        PulseDuration;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            
            obj.COM = 'COM5';
            obj.baudrate = 57600;
            obj.databits = 7;
            obj.parity = 'even';
            obj.timeout = 2;
            obj.terminator = {'CR','CR'};
            obj.SourceCH = 2;
            obj.Rf = PhysicalMeasurement;            
            obj.Rf.Value = 1e4;
            obj.Rf.Units = 'Ohm';
            obj.PulseAmp = PhysicalMeasurement;            
            obj.PulseAmp.Value = 40;
            obj.PulseAmp.Units = 'uA';
            obj.RL = PhysicalMeasurement;            
            obj.RL.Value = 0;
            obj.RL.Units = 'Ohm';  % Comprobar que es la unidad correcta
            obj.PulseDT = PhysicalMeasurement;            
            obj.PulseDT.Value = 1000;
            obj.PulseDT.Units = 'ms';  % Comprobar que es la unidad correcta
            obj.PulseDuration = PhysicalMeasurement;            
            obj.PulseDuration.Value = 2000;
            obj.PulseDuration.Units = 'us';  % Comprobar que es la unidad correcta
            

        end
        
        function obj = Initialize(obj)
            addpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Magnicon_Matlab\');
            obj = mag_init_updated(obj);
        end
        
        function Calibration(obj)
            out = mag_setRf_FLL_CH_updated(obj);
            if out == 'OK'
                disp('Initialization completed');
            else
                disp('Problem detected, check the connections!');
            end
        end       
        
        function TES2NormalState(obj,Ibias_sign)
            %%% Maximum current value is imposed
            Put_TES_toNormal_State_CH_updated(obj,Ibias_sign)
            
        end
        function ResetClossedLoop(obj) 
            %%% Clossed loop is reset
            mag_setAMP_CH_updated(obj);
            mag_setFLL_CH_updated(obj);
        end
        
        function Pulse_Configuration(obj)
            mag_Configure_CalPulse_updated(obj);        
        end
        
        function Cal_Pulse_ON(obj)
             mag_setCalPulseON_CH_updated(obj);
        end
        
        function Cal_Pulse_OFF(obj)
             mag_setCalPulseOFF_CH_updated(obj);
        end
        
        function Set_Current_Value(obj,Ibvalue)
            mag_setImag_CH_updated(obj,Ibvalue);
        end
        
        function Ireal = Read_Current_Value(obj)
            Ireal = PhysicalMeasurement;
            Ireal.Value = mag_readImag_CH_updated(obj);
            Ireal.Units = 'uA';
        end
        
        function Destructor(obj)
            try
                fclose(obj.ObjHandle);
            catch
            end
            delete(obj.ObjHandle);
            rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Magnicon_Matlab\');
        end
       
    end
    
end

