classdef CurrentSource
    % Class defining a Current Source.
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        Vmax;
        Imax;
        ObjHandle;
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.PrimaryAddress = 2;
            obj.BoardIndex = 1;
            obj.Vmax = PhysicalMeasurement;
            obj.Vmax.Value = 50;
            obj.Vmax.Units = 'V';
            obj.Imax = PhysicalMeasurement;
            obj.Imax.Value = 0.005;
            obj.Imax.Units = 'A';
            obj.ID = 'K220';
        end
        
        function [obj, status] = Initialize(obj)
            % Function that initialize the values of the source current
            
            [obj, status] = k220_init(obj);
            obj = k220_setVlimit(obj);
            I_initial.Value = 0;
            I_initial.Units = 'A';
            obj = SetIntensity(obj,I_initial);
            obj = CurrentSource_Stop(obj);
        end
        
        function obj = Calibration(obj)
            % Function that calibrates the V limit of the current source
            
            obj = k220_setVlimit(obj);
        end
        
        function obj = SetIntensity(obj,Ivalue)
            % Function to set the current value
            
            if strcmpi(Ivalue.Units, 'A')
                k220_setI(obj,Ivalue)
            else
                error('Ivalue units must be A');
            end
        end
        function obj = CurrentSource_Start(obj)
            % Function to start current output
            
            k220_Start(obj);
        end
        function obj = CurrentSource_Stop(obj)
            % Function to stop current output
            
            k220_Stop(obj);
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