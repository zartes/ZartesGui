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
        
        function  [f,N, obj] = NnoiseModel(obj,TES,Tbath)
            %%%Función para devolver el modelo de ruido total en estado normal o
            %%%superconductor
            
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
            RTES = TES.circuit.Rn.Value+RL;
            
            tau = TES.circuit.L.Value/(RL+TES.circuit.Rn.Value);
            f = logspace(0,6);
            w = 2*pi*f;
            
            i_jo = sqrt(4*TES.ElectrThermalModel.Kb*Tbath/(RTES))./(1+tau*w);
            %[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
            %N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
            N = sqrt(i_jo.^2+TES.circuit.Nsquid.Value^2);           
            
        end
        
        function [f,N,obj] = SnoiseModel(obj,TES,Tbath)
                        
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
                        
            tau = TES.circuit.L.Value/RL;
            f = logspace(0,6);
            w = 2*pi*f;
            %(Rf*invMf/invMin) factor para convertir en Voltaje.
            i_sh = sqrt(4*TES.ElectrThermalModel.Kb*Tbath/RL)./(1+tau*w);            
            N = sqrt(i_sh.^2+TES.circuit.Nsquid.Value^2);
            
        end
        
        function obj = Plot(obj,fig,TES,Type)
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
            try
                offsetstr = strfind(file,'mK_')-1;
                onsetstr = strfind(file,'_');
                onsetstr = onsetstr(find(offsetstr-onsetstr > 0,1,'last'))+1;
                Tbath = str2double(file(onsetstr:offsetstr))*1e-3;
            catch
                file(file == '_') = ' ';
                title(ax,file);
                waitfor(msgbox('Tbath was not identified from noise file in terms of ''_XXmK'' value, please provide a Tbath(mK) to continue',obj.version));
                prompt = {'Enter the Tbath value in mK:'};
                name = 'Theorical Noise estimation';
                numlines = 1;
                defaultanswer = {'50'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Tbath = str2double(char(answer));
                if isnan(Tbath)
                    warndlg('Invalid Tbath value',obj.version);                    
                    return;
                end
            end
            file(file == '_') = ' ';
            title(ax,file);
            
            % Autodetecta la temperatura del baño con _XXmK_
            switch Type
                case 'Normal'
                    [f,N, obj] = obj.NnoiseModel(TES,Tbath);
                    loglog(ax,f,N*1e12,'.-g','DisplayName','Theorical Normal Noise');
                case 'Superconductor'
                    [f,N, obj] = obj.SnoiseModel(TES,Tbath);
                    loglog(ax,f,N*1e12,'.-g','DisplayName','Theorical Superconductor Noise');                    
            end
             %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            
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