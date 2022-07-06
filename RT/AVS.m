classdef AVS
    % Class AVS for AVS-47B AC Resistance Bridge device
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        ObjHandle;
        Naverages;
        Rango;
        Ch;
        Excitacion;
    end
    
    methods
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.PrimaryAddress = 21;
            obj.BoardIndex = 1;%0->1. 
            obj.ID = 'PICOWATT,AVS47-IB,0,1.4';
            obj.Naverages = 10;
            obj.Rango = 1;
            obj.Ch = 1;
            obj.Excitacion = 1;
        end
        
        function [obj, status] = Initialize(obj)
            % Function that initialize the values of the AVS 47
            
            [obj, status] = avs_init(obj);                   
        end
        
        function obj = ChangeRango(obj,RAN)
            % Function to change output range
            
            obj.Rango = RAN;
            query(obj.ObjHandle,['RAN ' num2str(obj.Rango) ';']);            
        end
        
        function obj = ChangeExcitacion(obj,EXC)
            obj.Excitacion = EXC;
            query(obj.ObjHandle,['EXC ' num2str(obj.Excitacion) ';']);            
        end
        
        function obj = ChangeChannel(obj,CH)
            % Function to change channel for measuring
            
            obj.Ch = CH;
            query(obj.ObjHandle,['MUX ' num2str(obj.Ch) ';']);            
        end
        function [obj, R] = Read(obj)
            % Function to read AVS47 output
            
            R = PhysicalMeasurement;
            R.Value = avs_read(obj);
            R.Units = 'Ohm';
        end
        
        function Destructor(obj)
            % Function to delete the object class
            
            try
                query(obj.ObjHandle,'REM0'); % Poner el AVS en modo local
                fclose(obj.ObjHandle); % Valid after fopen
            catch
            end
            try
                delete(obj.ObjHandle);
            catch
            end
        end
    end
    
end

