classdef TES_BasalNoises
    % Class TFS for TES data
    %   This class contains transfer function in superconductor state
    
    properties
        fileNoise;
        fNoise;
        SigNoise;
    end
    
    properties (Access = private)
        version = 'ZarTES v2.1';
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.fileNoise = [];
            obj.NoiseModel = [];
            obj.fNoise = [];
            obj.SigNoise = [];
            obj.ExRes = [];
            obj.ThRes = [];
            obj.M = [];
            obj.Mph = [];
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
        
        function obj = NoisefromFile(obj,FileName,fig,TES)
            % Function to import Noise from file     
            obj.fileNoise = FileName;
            noisedata{1} = importdata(FileName);            
            obj.fNoise = noisedata{1}(:,1);            
            obj.SigNoise = TES.V2I(noisedata{1}(:,2)*1e12);
            
        end
        
        function obj = Plot(obj,fig)
            % Function that visualizes TFS
            
            if nargin < 2
                fig = figure;
            end
            figure(fig)
            ax = axes;
            hold on;
            grid on;
            loglog(ax,obj.fNoise(:,1),obj.SigNoise,'.-r','DisplayName','Experimental Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            loglog(ax,obj.fNoise(:,1),medfilt1(obj.SigNoise,40),'.-k','DisplayName','Exp Filtered Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            set(ax,'XScale','log','YScale','log')
            ylabel(ax,'pA/Hz^{0.5}');
            xlabel(ax,'\nu (Hz)');
            [path,file] = fileparts(obj.fileNoise);
            file(file == '_') = ' ';
            title(ax,file);
        end
        
        function obj = Check(obj,fig)
            % Function to check TFS visually
            
            obj.Plot(fig);
            ButtonName = questdlg('Is this Noise file valid?', ...
                obj.version, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'No'
                    obj = obj.Constructor;
                case 'Yes'
                    waitfor(msgbox('Noise file updated',obj.version));
            end
        end
        
    end
end