classdef Multimeter 
    % Class defining a multimeter to measure voltage.
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            obj.PrimaryAddress = 4;
            obj.BoardIndex = 0; 
            obj.ID = 'HP3458A';
        end
        
        function [obj, status] = Initialize(obj)            
            addpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Multimetro_HP3458A_Matlab\'); 
            [obj, status] = multi_init_updated(obj);                   
        end
        
        function Vdc = Read(obj)
            Vdc = PhysicalMeasurement;
            Vdc.Value = multi_read_updated(obj);
            Vdc.Units = 'mV';
        end
        
        function Destructor(obj)
            try
                fclose(obj.ObjHandle); % Valid after fopen
            catch
            end
            delete(obj.ObjHandle);
            rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Multimetro_HP3458A_Matlab\');
        end
    end
    
end
    

