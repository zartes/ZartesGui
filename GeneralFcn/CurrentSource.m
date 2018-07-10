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
            addpath('G:\Mi unidad\ICMA\zartes_ACQ-master\K220\'); 
            [obj, status] = k220_init_updated(obj);   
        end
        
        function obj = Calibration(obj)
            obj = k220_setVlimit_updated(obj);
        end
        
        function SetIntensity(obj,Ivalue)
            if strcmpi(Ivalue.Units, 'A')
                k220_setI_updated(obj,Ivalue)
            else
                error('Ivalue units must be A');
            end
        end
        function CurrentSource_Start(obj)
            k220_Start_updated(obj);
        end
        function CurrentSource_Stop(obj)
            k220_Stop_updated(obj);
        end
        
        function Destructor(obj)
            try
                fclose(obj.ObjHandle); % Valid after fopen
            catch
            end
            delete(obj.ObjHandle);
            rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\K220\');
        end
    end
    
end