classdef TES_BasalNoises
    % Class TFS for TES data
    %   This class contains transfer function in superconductor state
    
    properties
        fileNoise;
        fNoise;
        SigNoise;
    end
    
    properties (Access = private)
        version = 'ZarTES v4.4';
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
        
        function  [f,N,obj] = NnoiseModel(obj,TES,Tbath,Ttes)
            %%%Función para devolver el modelo de ruido total en estado normal o
            if nargin ~= 4
                Ttes=Tbath;
            end
            % Modelo de ruido en estado normal teórico
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
            RTES = TES.circuit.Rn.Value;
            % f = logspace(0,6,1001)';

            if size(TES.circuit.Nsquid.Value,1) == 1                
                f = logspace(0,6);
            else
                f = obj.fNoise;
            end
            
            w = 2*pi*f;
            Zcirc = RL+RTES+1i*w*TES.circuit.L.Value;% impedancia del circuito.
            v2_sh = 4*TES.ElectrThermalModel.Kb*max(Tbath,0.15)*RL; % ruido voltaje Rsh (mas parasita).
            v2_tes = 4*TES.ElectrThermalModel.Kb*Ttes*RTES;%ruido voltaje en el TES en estado normal.
%             i_jo = sqrt((v2_sh+v2_tes)./abs(Zcirc));
            i_jo = sqrt((v2_sh+v2_tes))./abs(Zcirc);
            
%             i_jo=sqrt(4*Kb*Tbath/(RTES))./(1+tau*w);
            
            if size(TES.circuit.Nsquid.Value,1) == 1
                %%%superconductor
                N = sqrt(i_jo.^2+TES.circuit.Nsquid.Value^2);
            else                
%                 N = TES.circuit.Nsquid.Value;
                N = sqrt((obj.SigNoise*1e-12).^2-i_jo.^2);
            end
                
            % Partiendo del ruido en estado Normal adquirido
            % experimentalmente
            
%             f = obj.fNoise;
%             w = 2*pi*f;
%             N = (obj.SigNoise*1e-12);
%             TES.circuit.Nsquid.Value = N;
%             
% %             tau = TES.circuit.L.Value/RTES;
%             f = obj.fNoise;
% %             f = logspace(0,6);
%             w = 2*pi*f;
%             
%             if nargin ~= 4 
%                 Ttes=Tbath;
%             end 
%             
%             Zcirc = RL+RTES+1i*w*TES.circuit.L.Value;% impedancia del circuito.
% %             v2_sh = 4*TES.ElectrThermalModel.Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
%             
%             v2_tes = 4*TES.ElectrThermalModel.Kb*Ttes*RTES;%ruido voltaje en el TES en estado normal.
%             i_Squid = (obj.SigNoise*1e-12).^2;
%             
% %             i_jo = sqrt(v2_sh+v2_tes)./abs(Zcirc);
%             i_jo = sqrt(v2_tes)./abs(Zcirc);
%             
%             %%i_jo=sqrt(4*Kb*Tbath/(RTES))./sqrt(1+(tau*w).^2);%%%06-04-20.no elevaba al cuadrado tau*w!!!
%             %i_jo=sqrt(4*Kb*Tbath/(RTES))./(1+tau*w);
%             %[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
%             %N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
%             
% %             N = sqrt(i_jo.^2+TES.circuit.Nsquid.Value^2);            
%             N = sqrt(i_jo.^2);
%             TES.circuit.Nsquid.Value = N;
%             i_jo = sqrt(4*TES.ElectrThermalModel.Kb*Tbath/(RTES))./(1+tau*w);
%             %[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
%             %N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
%             N = sqrt(i_jo.^2+TES.circuit.Nsquid.Value^2);           
            
        end
        
        function [f,N,obj] = SnoiseModel(obj,TES,Tbath)
                        
            RL = TES.circuit.Rsh.Value+TES.circuit.Rpar.Value;
                        
%             tau = TES.circuit.L.Value/RL;
            % f = logspace(0,6,1001);
            if size(TES.circuit.Nsquid.Value,1) == 1                
                f = logspace(0,6);
            else
                f = obj.fNoise;
            end
            w = 2*pi*f;
            
            Tc = 0;
            Rtes = 0; %TES estado superconductor.
            Ttes = max(Tbath,0.15);
            
            Zcirc = RL+Rtes+1i*w*TES.circuit.L.Value;% impedancia del circuito.
            v2_sh = 4*TES.ElectrThermalModel.Kb*Ttes*RL; % ruido voltaje Rsh (mas parasita).
            v2_tes = 4*TES.ElectrThermalModel.Kb*Ttes*Rtes;%ruido voltaje en el TES en estado superconductor. En realidad es cero, lo pongo así por mantener la misma estructura del ruido en estado normal.
            i_jo = sqrt(v2_sh+v2_tes)./abs(Zcirc);
            
            %(Rf*invMf/invMin) factor para convertir en Voltaje.
%             i_sh = sqrt(4*TES.ElectrThermalModel.Kb*Tbath/RL)./(1+tau*w);
            N = sqrt(i_jo.^2+TES.circuit.Nsquid.Value.^2);
            
        end
        
        function [obj, fig] = Plot(obj,fig,TES,Type)
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
            [path,file] = fileparts(obj.fileNoise);
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
                    [f,N, obj] = obj.SnoiseModel(TES,Tbath);
                    loglog(ax,f,N*1e12,'.-r','DisplayName','Theorical Superconductor Noise','LineWidth',2);                    
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