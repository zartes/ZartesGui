classdef Multimeter 
    % Class defining a multimeter to measure voltage.
    
    properties
        ID;
        PrimaryAddress;
        BoardIndex;
        ObjHandle;
        averages;
    end
    
    methods
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.PrimaryAddress = 4;
            obj.BoardIndex = 1; 
            obj.ID = 'HP3458A';
            obj.averages = 1;
        end
        
        function [obj, status] = Initialize(obj)     
            % Function that initialize the values of the multimeter HP3458A
            
            [obj, status] = multi_init(obj);                   
        end
        
        function [obj, Vdc] = Read(obj)
            % Function to read multimeter output
            
            Vdc = PhysicalMeasurement;
            Vdc.Value = multi_read(obj);
            Vdc.Units = 'V';
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
    

