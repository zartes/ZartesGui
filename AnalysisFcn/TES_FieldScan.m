classdef TES_FieldScan
    % Class Circuit for TES data
    %   Circuit represents the electrical components in the TES
    %   characterization.
    
    properties
        B;
        Vout;
        Ibias;
        Tbath;
    end
    
    properties (Access = private)
        version = 'ZarTES v4.2';
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.B = [];
            obj.Vout = [];
            obj.Ibias = [];
            obj.Tbath = [];
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i}]))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))                        
                        eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                    end
                end
                
            end
        end
        
        function [obj, Status] = ImportScan(obj,DataPath,fig)
            % Function to complete the class with experimental data (Rf, mN and
            % mS)
            Status = 1;
            if exist(DataPath,'dir')
                path = uigetdir(DataPath,'Pick a Data path containing Field Scan files (Barrido_Campo dir)');
            else
                path = uigetdir('G:\Unidades de equipo\ZARTES\DATA\*','Pick a Data path containing Field Scan files');
            end
            
            if isequal(path,0)
                waitfor(errordlg('Invalid Data path name!',obj.version,'modal'));
                Status = 0;
                return;
            end
            
            d = dir([path filesep 'BVscan*.mat']);
            if isempty(d)
                d = dir([path filesep 'BVscan*.txt']);
                if isempty(d)
                    waitfor(errordlg('No Data on this path!',obj.version,'modal'));
                    Status = 0;
                    return;                    
                end
            end                        
            
            wb = waitbar(0,'Please wait...');
            
            for i = 1:length(d)
                try
                    BV = load([path filesep d(i).name]);
                    obj.B{i} = [BV.B];
                    obj.Vout{i} = [BV.V];
                catch
                    BV = importdata([path filesep d(i).name]);
                    obj.B{i} = BV(:,2);
                    obj.Vout{i} = BV(:,5);
                end
                try
                    obj.Tbath{i} = sscanf(char(regexp(d(i).name,'\d+.?\d+mK*','match')),'%fmK')*1e-3;
                catch
                    obj.Tbath{i} = NaN;
                end
                try
                    obj.Ibias{i} = sscanf(char(regexp(d(i).name,'\d+.?\d+uA*','match')),'%fuA');
                catch
                    obj.Ibias{i} = NaN;
                end
                %%%ojo al %d o %0.1f
                % Añadido para identificar de donde procede la informacion
                
                if ishandle(wb)
                    waitbar(i/length(d),wb,['Loading FieldScan files in progress: ' num2str(obj.Tbath{i}*1e3) ' mK']);
                end
                
            end
            if ishandle(wb)
                delete(wb);
            end
        end
        
        
        
    end
end

