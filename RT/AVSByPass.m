classdef AVSByPass
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        s = [];        
    end
    
    methods
        function obj = AVSByPass_init(obj,COM)
            %Funcion para inicializar la comunicacion con la electronica magnicon.
            if nargin == 1
                COM='COM9';
            else
                COM = 'GPIB1::21::INSTR'
            end
            
            %COM='COM9';%puerto serie.
            obj.s=instrfind('type','serial','Port',COM);
                        
            switch length(obj.s)
                case 0
                    obj.s=serial(COM);
                    fopen(obj.s);
                case 1
                    if (strcmp(obj.s.Status,'closed')) fopen(obj.s);end
                otherwise
                    for i=2:length(obj.s) delete(obj.s(i));end
                    obj.s=obj.s(1);
                    if (strcmp(obj.s.Status,'closed')) fopen(obj.s);end
            end
            %port configuration
            set(obj.s,'baudrate',9600,'databits',8,'parity','none','timeout',1);
        end
        
        function SetCurrent(obj,uA)
%             RectaAjuste = 179.75; (Valor a ojimetro por Nico y Juan)
            RectaAjuste = 160; % Valor a fecha de 02/06/2022
%             RectaAjuste = 161.183; (Primer valor de Pedro)
            x = num2str(RectaAjuste*uA);    
            if (strcmp(obj.s.Status,'closed'))
                fopen(obj.s);
                out = query(obj.s,['i' x]);
                fclose(obj.s);
            else
                out = query(obj.s,['i' x]);
                fclose(obj.s);
            end
                                   
        end        
    end
    
end

