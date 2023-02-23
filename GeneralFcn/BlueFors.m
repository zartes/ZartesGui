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
        P = 0.01;
        I = 250;
        D = 0;
        SetPt = 0;
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
            try
                msg = webread(obj.Mixing_url);
                while msg.channel_nr ~= obj.MixingChannel
                    msg = webread(obj.Mixing_url);
                end
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.Mixing_url);
                end
                Temp = msg.temperature;
            catch me
                msg = webread(obj.Mixing_url);
                while msg.channel_nr ~= obj.MixingChannel
                    msg = webread(obj.Mixing_url);
                end
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.Mixing_url);
                end
                Temp = msg.temperature;
            end
        end
        
        function Power = ReadPower(obj)
            try
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                Power = msg.data(4).power;
            catch me
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                Power = msg.data(4).power;
            end
        end
        
        function MaxPower = ReadMaxPower(obj)
            try
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                MaxPower = msg.data(4).max_power;
            catch
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                MaxPower = msg.data(4).max_power;
            end
        end
        
        function SetPoint = ReadSetPoint(obj)
            try
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                SetPoint = msg.data(4).setpoint;
            catch me
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                SetPoint = msg.data(4).setpoint;
            end
        end
        
        function PID_mode = ReadPIDStatus(obj)
            try
                msg = webread(obj.HeaterRead_url);
                while ~strcmp(msg.status,'OK')
                    msg = webread(obj.HeaterRead_url);
                end
                PID_mode = msg.data(4).pid_mode;
            catch me
                disp(me);
            end
        end
        
        function SetTemp(obj,T)
            % Temperature en mK
            msg = webread(obj.HeaterRead_url);
            while ~strcmp(msg.status,'OK')
                obj.Heater = SimpleClient(obj.HeaterWrite_url);
                msg = webread(obj.HeaterRead_url);
            end
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "setpoint":' num2str(T) '}'];
            obj.Heater.send(message);
        end
        
        function SetPID(obj,P,I,D)
            
            message = ['{"heater_nr": ' num2str(obj.HeaterNum) ', "control_algorithm_settings": {"proportional": ' num2str(P) ', "integral": ' num2str(I) ', "derivative": ' num2str(D) '}}'];
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

