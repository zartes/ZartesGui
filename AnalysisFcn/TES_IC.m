classdef TES_IC
    % Class Circuit for TES data
    %   Circuit represents the electrical components in the TES
    %   characterization.
    
    properties
        B;
        p;
        n;
        Tbath;
    end
    
    properties (Access = private)
        version = 'ZarTES v3.0';
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.B = [];
            obj.p = [];
            obj.n = [];
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
        
        function [obj, Status] = ImportICs(obj,DataPath,fig)
            % Function to complete the class with experimental data (Rf, mN and
            % mS)
            Status = 1;
            if exist(DataPath,'dir')
                path = uigetdir(DataPath,'Pick a Data path containing IC files (Barrido_Campo dir)');
            else
                path = uigetdir('G:\Unidades de equipo\ZARTES\DATA\*','Pick a Data path containing IC files');
            end
            
            if isequal(path,0)
                waitfor(errordlg('Invalid Data path name!',obj.version,'modal'));   
                Status = 0;
                return;
            end
            d = dir([path filesep 'ICpairs*.mat']);
            if isempty(d)
                d = dir([path filesep 'ICpairs*.txt']);
                if isempty(d)
                    waitfor(errordlg('No Data on this path!',obj.version,'modal'));
                    Status = 0;
                    return;                    
                end
            end                        
            
            wb = waitbar(0,'Please wait...');
            
            for i = 1:length(d)
                try
                    IC = load([path filesep d(i).name]);
                    obj.B{i} = [IC.ICpairs.B];
                    obj.p{i} = [IC.ICpairs.p];
                    obj.n{i} = [IC.ICpairs.n];
                catch
                    IC = importdata([path filesep d(i).name]);
                    obj.B{i} = IC(:,1);
                    obj.p{i} = IC(:,2);
                    obj.n{i} = IC(:,3);
                end
                obj.Tbath{i} = sscanf(char(regexp(d(i).name,'\d+.?\d+mK*','match')),'%fmK')*1e-3;
                
                %%%ojo al %d o %0.1f
                % Añadido para identificar de donde procede la informacion
                
                if ishandle(wb)
                    waitbar(i/length(d),wb,['Loading IC files in progress: ' num2str(obj.Tbath{i}*1e3) ' mK']);
                end
                
            end
            if ishandle(wb)
                delete(wb);
            end
        end
        
        
        
    end
end

