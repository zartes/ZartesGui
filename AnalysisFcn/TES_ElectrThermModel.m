classdef TES_ElectrThermModel
    % Class TF for TES data
    %   This class contains options for Z(W) analysis
    
    properties              
        AvailableModels = {'1TB';'2TB (Hanging)';'2TB (Intermediate)'} % One Single Thermal Block, Two Thermal Blocks
        SelectedModel = 1;
        Options = {'No restriction';'Fixing C'};
        OptionsVal = 1;
        StrModelPar = {[]};
        boolShow = 1;                               % 0,1
        TFBaseName = '\TF*';           
        R2Thrs = 0.9;
        
        tipo = 'current';               % current, nep
        boolcomponents = 0;             % 0,1
        Mjo = 0;                        % Jonson noise 0,1
        Mph = 0;                        % Phonon noise 0,1
        NoiseBaseName = '\HP_noise*';   % \HP_noise*, \PXI_noise*
        NoiseModel = {'irwin';'2TB (Hanging)';'2TB (Intermediate)'};           % irwin, wouter
        LowFreq = 1e2;
        HighFreq = 10e4;
        MedFilt = 40;
    end
    
    methods
        
        function obj = Constructor(obj)
            switch obj.AvailableModels{obj.SelectedModel}
                case obj.AvailableModels{1}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff'};          % 3 parameters
                case obj.AvailableModels{2}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                case obj.AvailableModels{3}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                case obj.AvailableModels{4}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff';'tau1';'tau2';'d1';'d2'};                    
            end
        end
        
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_ElectrThermModel');
            waitfor(Conf_Setup(h,[],obj));
            TF_Opt = guidata(h);
            if ~isempty(TF_Opt)
                obj = obj.Update(TF_Opt);
            end
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
        
        function [param, ztes, fZ, fS, ERP, R2, CI, aux1, p0] = FitZ(obj,TES,FileName,FreqRange)
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:length(FileName));
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK');
            Ib = str2double(Name(find(Name == '_', 1, 'last')+1:strfind(Name,'uA.txt')-1))*1e-6;
            % Buscamos si es Ibias positivos o negativos
            if ~isempty(strfind(Path,'Negative')) %#ok<STREMP>
                [~,Tind] = min(abs([TES.IVsetN.Tbath]*1e3-Tbath));
                IV = TES.IVsetN(Tind);
                CondStr = 'N';
            else
                [~,Tind] = min(abs([TES.IVsetP.Tbath]*1e3-Tbath));
                IV = TES.IVsetP(Tind);
                CondStr = 'P';
            end
            % Primero valoramos que este en la lista
            filesZ = ListInBiasOrder([Path TES.TFOpt.TFBaseName])';
            SearchFiles = strfind(filesZ,Name);
            for i = 1:length(filesZ)
                if ~isempty(SearchFiles{i})
                    IndFile = i;
                    break;
                end
            end
            try
                eval(['[~,Tind] = find(abs([TES.P' CondStr '.Tbath]*1e3-Tbath)==0);']);
                eval(['ztes = TES.P' CondStr '(Tind).ztes{IndFile};'])
                eval(['fS = TES.P' CondStr '(Tind).fS{IndFile};'])
                if isempty(ztes)
                    error;
                end
            catch
                data = importdata(FileName);
                IndDist = find(data(:,2) ~= 0);
                data = data(IndDist,:);                
                tf = data(:,2)+1i*data(:,3);
                Rth = TES.circuit.Rsh+eval(['TES.TES' CondStr '.Rpar'])+2*pi*TES.circuit.L*data(:,1)*1i;                
                fS = TES.TFS.f(IndDist);                                
                ztes = (TES.TFS.tf(IndDist)./tf-1).*Rth;                
                ztes = ztes(fS >= FreqRange(1) & fS <= FreqRange(2));
                fS = fS(fS >= FreqRange(1) & fS <= FreqRange(2));                
            end
            Zinf = real(ztes(end));
            Z0 = real(ztes(1));
            [~,indfS] = min(imag(ztes));
            tau0 = 1/(2*pi*fS(indfS));
            opts = optimset('Display','off','Algorithm','levenberg-marquardt');
            switch obj.AvailableModels{obj.SelectedModel}
                case obj.AvailableModels{1}
                    p0 = [Zinf Z0 tau0];          % 3 parameters
                case obj.AvailableModels{2}
                    ca0 = 1e-1;
                    tauA = 1e-6;
                    p0 = [Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                case obj.AvailableModels{3}
                    ca0 = 1e-1;
                    tauA = 1e-6;
                    p0 = [Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                case obj.AvailableModels{4}
                    tau1 = 1e-5;
                    tau2 = 1e-5;
                    d1 = 0.8;
                    d2 = 0.1;
                    p0 = [Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.   % 7 parameters                                        
            end
            [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@obj.fitZ,p0,fS,...
                [real(ztes) imag(ztes)],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
            MSE = (aux2'*aux2)/(length(fS)-length(p)); %#ok<NASGU>
            ci = nlparci(p,aux2,'jacobian',jacob);
            CI = (ci(:,2)-ci(:,1))';  
            p_CI = [p; CI];
            param = obj.GetModelParameters(TES,p_CI,IV,Ib,CondStr);
            fZ = obj.fitZ(p,fS);
            ERP = sum(abs(abs(ztes-fZ(:,1)+1i*fZ(:,2))./abs(ztes)))/length(ztes);
            R2 = goodnessOfFit(fZ(:,1)+1i*fZ(:,2),ztes,'NRMSE');
            
        end
        
        function fz = fitZ(obj,p,f)
            % Function to fit Z(w) according to the selected
            % electro-thermal model
            
            w = 2*pi*f;
            D = (1+(w.^2)*(p(3).^2));
            switch obj.AvailableModels{obj.SelectedModel}
                case obj.AvailableModels{1}
                    rfz = p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
                    imz = -(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
                    imz = -abs(imz);
                case obj.AvailableModels{2}
                    fz = p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
                    rfz = real(fz);
                    imz = -abs(imag(fz));
                case obj.AvailableModels{3}
                    fz = p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
                    rfz = real(fz);
                    imz = -abs(imag(fz));
                case obj.AvailableModels{4}
                    %p=[Zinf Z0 tau_I tau_1 tau_2 d1 d2]. Maasilta IH.
                    fz = p(1)+(p(2)-p(1)).*(1-p(6)-p(7)).*(1+1i*w*p(3)-p(6)./(1+1i*w*p(4))-p(7)./(1+1i*w*p(5))).^-1;
                    rfz = real(fz);
                    imz = -abs(imag(fz));
            end
            fz = [rfz imz];
        end
        
        function param = GetModelParameters(obj,TES,p,IVmeasure,Ib,CondStr)
            Rn = eval(['TES.TES' CondStr '.Rn;']);
            
            T0 = eval(['TES.TES' CondStr '.Tc;']); %(K)
            G0 = eval(['TES.TES' CondStr '.G']);  %(W/K)
            
            IVmeasure.vout = IVmeasure.vout+1000;  % Sumo 1000 para que toda la curva IV
            %sea positiva siempre, que no haya cambios de signo para que los splines no devuelvan valores extraños
            % Luego se restan los 1000.
            [iaux,ii] = unique(IVmeasure.ibias,'stable');
            vaux = IVmeasure.vout(ii);
            [m,i3] = min(diff(vaux)./diff(iaux)); %#ok<ASGLU>
            
            Vout = ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);
            IVaux.ibias = Ib;
            IVaux.vout = Vout-1000;
            IVaux.Tbath = IVmeasure.Tbath;
            
            F = TES.circuit.invMin/(TES.circuit.invMf*TES.circuit.Rf);%36.51e-6;
            I0 = IVaux.vout*F;
            Vs = (IVaux.ibias-I0)*TES.circuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            V0 = Vs-I0*eval(['TES.TES' CondStr '.Rpar;']);
            
            P0 = V0.*I0;
            R0 = V0/I0;
            
            param.R0 = R0;
            
            switch obj.AvailableModels{obj.SelectedModel}
                case obj.AvailableModels{1}
                    rp = p(1,:);
                    rp_CI = p(2,:);
                    rp(1,3) = abs(rp(3));
                    param.rp = R0/Rn;
                    
                    param.Zinf = rp(1);
                    param.Zinf_CI = rp_CI(1);
                    
                    param.Z0 = rp(2);
                    param.Z0_CI = rp_CI(2);
                    
                    param.taueff = rp(3);
                    param.taueff_CI = rp_CI(3);
                    
                    param.L0 = (param.Z0-param.Zinf)/(param.Z0+R0);
                    param.L0_CI = sqrt((((param.Zinf+R0)/((param.Z0+R0)^2))*param.Z0_CI)^2 + ((-1/(R0 + param.Z0))*param.Zinf_CI)^2 );
                    
                    param.Z0Zinf = (param.Z0-param.Zinf);
                    param.Z0R0 = (param.Z0+R0);
                    
                    param.ai = param.L0*G0*T0/P0;
                    param.ai_CI = (G0*T0/P0)*param.L0_CI;
                    
                    param.bi = (param.Zinf/R0)-1;
                    param.bi_CI = (1/R0)*param.Zinf_CI;
                    
                    
                    param.tau0 = param.taueff*(param.L0-1);
                    param.tau0_CI = sqrt(((param.L0-1)*param.taueff_CI)^2 + ((param.taueff)*param.L0_CI)^2 );
                    
                    param.C = param.tau0*G0;
                    param.C_CI = G0*param.tau0_CI;
                    
                case obj.AvailableModels{2}
                    % hay que definir estos parámetros
                    rp = p(1,:);
                    rp_CI = p(2,:);
                    rp(1,3) = abs(rp(3));
                    %derived parameters for 2 block model case A
                    param.rp = R0/Rn;
                    param.L0 = (rp(2)-rp(1))/(rp(2)+R0);
                    param.ai = param.L0*G0*T0/P0;
                    param.bi = (rp(1)/R0)-1;
                    param.tau0 = rp(3)*(param.L0-1);
                    param.taueff = rp(3);
                    param.C = param.tau0*G0;
                    param.Zinf = rp(1);
                    param.Z0 = rp(2);
                    param.CA = param.C*rp(4)/(1-rp(4));
                    param.GA = param.CA/rp(5);
                    param.tauA = rp(5);
                    param.ca0 = rp(4);
                    
                case obj.AvailableModels{3}
                    param = nan;
                case  obj.AvailableModels{4}
                    param = nan;
            end
        end                
        
        
    end
end