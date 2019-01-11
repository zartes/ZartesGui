classdef ElectronicMagnicon
    % Class of Electronic Magnicon
    
    properties
        COM;
        baudrate;
        databits;
        parity;
        timeout;
        terminator;
        SourceCH;
        Rf;
        LNCS_ILimit;
        PulseAmp;
        RL;        
        PulseDT;
        PulseDuration;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
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
            
            obj.LNCS_ILimit = PhysicalMeasurement;
            obj.LNCS_ILimit.Value = 5000;
            obj.LNCS_ILimit.Value = 'uA';
            
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
            % Function that initialize the values of the electronic
            % magnicon
            
            obj = mag_init(obj);
        end
        
        function obj = Calibration(obj)
            % Function to set Rf impedance of feedback loop
            
            [obj, out] = mag_setRf_FLL_CH(obj);
            if strcmp(out, 'OK')
                disp('Initialization completed');
            else
                disp('Problem detected, check the connections!');
            end
        end       
        
        function TES2NormalState(obj,Ibias_sign)
            % Function to put TES in normal state
            
            out = Put_TES_toNormal_State_CH(obj,Ibias_sign);           
            if out == 0
                msgbox('Action stopped by user','ZarTES v1.0');
                return;
            end
            status = obj.CheckNormalState;% status == 1 Normal State reached % status == 0 Superconductor State
            if status == 0
                msgbox('Normal State was not reach','ZarTES v1.0');
            end
%             Ibias = 500;
%             while status == 0
%                 mag_ConnectLNCS(obj);
%                 mag_setLNCSImag(obj,signo*Ibias*1.25);                
%                 % In the case of using the source in channel 1, it is mandatory to remove
%                 % the LNCS device.
%                 mag_setImag_CH(obj,signo*500);
%                 mag_setLNCSImag(obj,0);
%                 mag_DisconnectLNCS(obj);
%                 status = obj.CheckNormalState;
%                 Ibias = Ibias*1.25;
%             end                        
            
        end
        
        function status = CheckNormalState(obj)
            % Function to check TES normal state
            
            Ibvalue = [500 490 480];
            Ivalues = zeros(1,3);
            for i = 1:length(Ibvalue)
                obj.Set_Current_Value(Ibvalue(i));
                Ireal = obj.Read_Current_Value;
                Ivalues(i) = Ireal.Value;
            end
            P = polyfit(Ibvalue,Ivalues,1);
            if P(1)/obj.Rf.Value < 1 % Normal State Reached (Normalized Slope by Rf value)
                status = 1;
            else
                status = 0;
            end
        end
        
        function ResetClossedLoop(obj) 
            % Function to reset the clossed loop
            
            out = 'FAIL';
            while strcmp(out,'FAIL')
                mag_setAMP_CH(obj);
                out = mag_setFLL_CH(obj);
                pause(0.2);
            end
        end
        
        function Pulse_Configuration(obj)
            % Configuration for pulses as input
            
            mag_Configure_CalPulse(obj);
        end
        
        function status = Cal_Pulse_ON(obj)
            % Function to turn on the input
            
            status = mag_setCalPulseON_CH(obj);
        end
        
        function status = Cal_Pulse_OFF(obj)
            % Function to turn off the input
            
            status = mag_setCalPulseOFF_CH(obj);
        end
        
        function Set_Current_Value(obj,Ibvalue)
            % Function to set Ibias
            
            mag_setImag_CH(obj,Ibvalue);            
        end
        
        function Ireal = Read_Current_Value(obj)
            % Function to measure real Ibias
            
            Ireal = PhysicalMeasurement;
            Ireal.Value = mag_readImag_CH(obj);
            Ireal.Units = 'uA';                        
        end
        
        function Set_Current_Value_LNCS(obj,Ibvalue)
            % Function to set I bias by LNCS (Low Noise Current Source)
            
            mag_setLNCSImag(obj,Ibvalue);
        end
        
        function Ireal = Read_Current_Value_LNCS(obj)
            % Function to measure real Ibias by LNCS (Low Noise Current Source)
            
            Ireal = PhysicalMeasurement;
            Ireal.Value = mag_readLNCSImag(obj);
            Ireal.Units = 'uA';
        end
        
        function Connect_LNCS(obj)
            % Function to connect LNCS (Low Noise Current Source)
            
            mag_ConnectLNCS(obj);
        end
        
        function Disconnect_LNCS(obj)
            % Function to disconnect LNCS (Low Noise Current Source)
            
            mag_DisconnectLNCS(obj);
        end
        
        function Destructor(obj)
            % Function to delete the object class
            
            try
                fclose(obj.ObjHandle);
            catch
            end
            delete(obj.ObjHandle);
        end
       
    end
    
end

