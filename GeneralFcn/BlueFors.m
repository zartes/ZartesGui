classdef BlueFors
    %BLUEFORS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        IP = '192.168.2.121'
        Mixing_url;
        MixingChannel = 6;
        HeaterWrite_url;
        HeaterRead_url;
        HeaterNum = 4;
        Heater;
        P = 0.001;
        I = 2;
        D = 0.0005;
    end    
    
    methods
        function obj = Constructor(obj)            
            obj.Mixing_url = ['http://' obj.IP ':5001/channel/measurement/latest'];
            obj.HeaterWrite_url = ['ws://' obj.IP ':5002/heater/update'];
            obj.HeaterRead_url = ['http://' obj.IP ':5001/heaters'];
            obj.Heater = SimpleClient(obj.HeaterWrite_url);     
%             obj.HeaterRead = SimpleClient(obj.HeaterRead_url);     
        end
        
        function Temp = ReadTemp(obj)
            msg = webread(obj.Mixing_url);
            while msg.channel_nr ~= obj.MixingChannel
                msg = webread(obj.Mixing_url);
            end
            Temp = msg.temperature;
        end
        
        function Power = ReadPower(obj)
            msg = webread(obj.HeaterRead_url);
            Power = msg.data(4).power;
        end
        
        function MaxPower = ReadMaxPower(obj)
            msg = webread(obj.HeaterRead_url);
            MaxPower = msg.data(4).max_power;
        end
        
        function SetPoint = ReadSetPoint(obj)
            msg = webread(obj.HeaterRead_url);
            SetPoint = msg.data(4).setpoint;
        end
        
        function PID_mode = ReadPIDStatus(obj)
            msg = webread(obj.HeaterRead_url);
            PID_mode = msg.data(4).pid_mode;
        end
        
        function SetTemp(obj,T)
            % Temperature en mK
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "setpoint":' num2str(T) '}'];
            obj.Heater.send(message);
        end
        
        function SetPID(obj,P,I,D)
            
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "control_algorithm_settings": {"proportional": ' num2str(P) ', "integral": ' num2str(I) ', "derivative": ' num2str(D) '}'];
            obj.Heater.send(message);
        end
        
        function SetTempControl(obj,Mode)            
            % Mode: 0 (Manual)
            % Mode: 1 (PID)
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "pid_mode": ' num2str(Mode) '}'];
            obj.Heater.send(message);                       
        end
        
        function SetPower(obj,Power)
            % Se cambia a modo manual de forma automatica
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "pid_mode": 0, "power": ' num2str(Power) '}'];            
            obj.Heater.send(message);    
        end
        
        function SetMaxPower(obj,MaxPower)
            % Se cambia a modo manual de forma automatica
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "pid_mode": 0, "max_power": ' num2str(MaxPower) '}'];            
            obj.Heater.send(message);    
        end
        
    end
    
end

