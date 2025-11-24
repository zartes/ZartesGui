classdef TES_BasalNoises
    % Class TFS for TES data
    %   This class contains transfer function in superconductor state
    
    properties
        fileNoise;
        fNoise;
        SigNoise;
    end
    
    properties (Access = private)
        version = 'ZarTES v5.0';
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
            obj.M_CI = [];
            obj.Mph = [];            
            obj.Mph_CI = [];
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
        
        function  [f,N,obj] = NnoiseModel(obj,TES,Tbath,Ttes)
            %%%Función para devolver el modelo de ruido total en estado normal o
%           
                

            
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
            f = obj.fNoise;
            w = 2*pi*f;
            Rtes = TES.circuit.Rn.Value;

            Zcirc = RL+Rtes+1i*w*TES.circuit.L.Value;% impedancia del circuito.

            clear v2_sh i_jo

            v2_sh = 4*TES.ElectrThermalModel.Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
            v2_tes = 4*TES.ElectrThermalModel.Kb*Tbath*Rtes;%ruido voltaje en el TES en estado superconductor. En realidad es cero, lo pongo así por mantener la misma estructura del ruido en estado normal.
            i_jo = sqrt(v2_sh+v2_tes)./abs(Zcirc);

            if size(TES.circuit.Nsquid.Value,1) == 1
                N = sqrt(i_jo.^2+(ones(length(i_jo),1)*TES.circuit.Nsquid.Value.^2));
            else
                N = medfilt1(real(sqrt((obj.SigNoise*1e-12).^2-i_jo.^2)),40);
            end

            
        end
        
        function [f,N,TES,obj] = SnoiseModel(obj,TES,~)
                        
            %% Código nuevo adaptando Ttes
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
            f = obj.fNoise;
            w = 2*pi*f;
            Rtes = 0; %TES estado superconductor.            
            
            Zcirc = RL+Rtes+1i*w*TES.circuit.L.Value;% impedancia del circuito.
            
            Tsquid = 0.01:0.0025:0.4;
            N = NaN(length(Zcirc),length(Tsquid));
            Residuo = NaN(length(Zcirc),length(Tsquid));
            for i = 1:length(Tsquid)
                clear v2_sh i_jo

                v2_sh = 4*TES.ElectrThermalModel.Kb*Tsquid(i)*RL; % ruido voltaje Rsh (mas parasita).
                % v2_tes = 4*TES.ElectrThermalModel.Kb*Ttes(i)*Rtes;%ruido voltaje en el TES en estado superconductor. 
                % En realidad es cero, lo pongo así por mantener la misma estructura del ruido en estado normal.
                i_jo = sqrt(v2_sh)./abs(Zcirc);

                N(:,i) = sqrt(i_jo.^2+(ones(length(i_jo),1)*TES.circuit.Nsquid.Value.^2));
                Residuo(:,i) = abs(medfilt1(obj.SigNoise,40)-N(:,i)*1e12);
            end
            [~, ind] = min(sum(Residuo,1));
            
            N = N(:,ind);
            TES.SQUIDTemp = Tsquid(ind);





            
        end
        
        function [obj, fig, SQUIDTemp] = Plot(obj,fig,TES,Type)
            % Function that visualizes TFS
            
            if nargin < 2
                fig = figure;
            end
            figure(fig)
            ax = axes;
            hold on;
            grid on;
            loglog(ax,obj.fNoise(:,1),obj.SigNoise,'color',[0 0.447 0.741],...
            'markerfacecolor',[0 0.447 0.741],'DisplayName','Experimental Noise','LineWidth',1.5); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            loglog(ax,obj.fNoise(:,1),medfilt1(obj.SigNoise,40),'.-k','DisplayName','Exp Filtered Noise','LineWidth',1.5); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            set(ax,'XScale','log','YScale','log','FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on');
            ylabel(ax,'pA/Hz^{0.5}','FontSize',12,'FontWeight','bold');
            xlabel(ax,'\nu (Hz)','FontSize',12,'FontWeight','bold');
            [~,file] = fileparts(obj.fileNoise);
            try
                offsetstr = strfind(file,'mK')-1;
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
                Tbath = str2double(char(answer))*1e-3;
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
                    loglog(ax,f,N*1e12,'.-r','DisplayName','Theorical Normal Noise','LineWidth',2);
                case 'Superconductor'
                    [f,N,TES,obj] = obj.SnoiseModel(TES,Tbath);
                    loglog(ax,f,N*1e12,'.-r','DisplayName','Theorical Superconductor Noise','LineWidth',2);  
                    SQUIDTemp = TES.SQUIDTemp;
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