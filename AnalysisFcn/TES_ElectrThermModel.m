classdef TES_ElectrThermModel
    % Class TF for TES data
    %   This class contains options for Z(W) analysis
    
    properties              
        Zw_Models = {'1TB';'2TB (Hanging)';'2TB (Intermediate)'} % One Single Thermal Block, Two Thermal Blocks
        Selected_Zw_Models = 1;
        Options = {'No restriction';'Fixing C'};
        Selected_Options = 1;
        StrModelPar = {[]};
        bool_Show = 1;      
        TF_BaseName = {'HP';'PXI'};% 0,1
        Selected_TF_BaseName = 1;
        Zw_R2Thrs = 0.9;
        Zw_LowFreq = 1;
        Zw_HighFreq = 100000;
        Zw_rpLB = 0;
        Zw_rpUB = 1;        
        Z0_Zinf_Thrs = 1.5e-3;
        
        tipo = {'current';'nep'};               % current, nep
        Selected_tipo = 1;
        bool_components = 0;             % 0,1
        bool_Mjo = 0;                        % Jonson noise 0,1
        bool_Mph = 0;                        % Phonon noise 0,1        
        Noise_BaseName = {'HP';'PXI'};   % \HP_noise*, \PXI_noise*
        Selected_NoiseBaseName = 1;
        Noise_Models = {'irwin';'2TB (Hanging)';'2TB (Intermediate)';'wouter'};           % irwin, wouter
        Selected_Noise_Models = 1;
        Noise_LowFreq = [2e2 1e3]; % [2e2,1e3]
        Noise_HighFreq = [5e3,1e5]; %10e4; %[5e3,1e5]
        Kb = 1.38e-23;
        
        FilterMethods = {'nofilt';'medfilt';'minfilt';'minfilt+medfilt';'movingMean';'quantile'};
        Selected_FilterMethods = 5;
        MedFilt = 40;
        MinWindow = 6;
        Perc = 25;
        
    end
    properties (Access = private)
        version = 'ZarTES v4.1';
    end
    
    methods
        
        function obj = Constructor(obj)
            switch obj.Zw_Models{obj.Selected_Zw_Models}
                case obj.Zw_Models{1}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff'};          % 3 parameters
                case obj.Zw_Models{2}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                case obj.Zw_Models{3}
                    obj.StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                case obj.Zw_Models{4}
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
%                 OffsetY = TES.IVsetN(1).Offset(1);
                Ib = Ib - TES.circuit.CurrOffset.Value;
            else
                [~,Tind] = min(abs([TES.IVsetP.Tbath]*1e3-Tbath));
                IV = TES.IVsetP(Tind);
                CondStr = 'P';
%                 OffsetY = TES.IVsetP(1).Offset(1);
                Ib = Ib - TES.circuit.CurrOffset.Value;
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
                Rth = TES.circuit.Rsh.Value+eval(['TES.TESParam' CondStr '.Rpar.Value'])+2*pi*TES.circuit.L.Value*data(:,1)*1i;                
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
            switch obj.Zw_Models{obj.Selected_Zw_Models}
                case obj.Zw_Models{1}
                    p0 = [Zinf Z0 tau0];          % 3 parameters
                case obj.Zw_Models{2}
                    ca0 = 1e-1;
                    tauA = 1e-6;
                    p0 = [Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                case obj.Zw_Models{3}
                    ca0 = 1e-1;
                    tauA = 1e-6;
                    p0 = [Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                case obj.Zw_Models{4}
                    tau1 = 1e-5;
                    tau2 = 1e-5;
                    d1 = 0.8;
                    d2 = 0.1;
                    p0 = [Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.   % 7 parameters                                        
            end
%             RZtes = real(ztes);
%             IZtes = imag(ztes);
%             [minIZtes, ind] = min(IZtes);
%             FirstIZtes = IZtes(1:ind);
%             LastIZtes = IZtes(ind+1:end);
%             FirstRZtes = RZtes(1:ind);
%             LastRZtes = RZtes(ind+1:end);
%             FirstfS = fS(1:ind);
%             LastfS = fS(ind+1:end);
%                         
%             NewFirstIztes = linspace(FirstIZtes(1),FirstIZtes(end),321);
%             NewFirstRztes = interp1(FirstIZtes,FirstRZtes,NewFirstIztes);
%             
%             NewFirstfS = interp1(FirstRZtes,FirstfS,NewFirstRztes);
%             
%             NewLastIztes = linspace(LastIZtes(1),LastIZtes(end),321);
%             NewLastRztes = interp1(LastIZtes,LastRZtes,NewLastIztes);
%             NewLastfS = interp1(LastRZtes,LastfS,NewLastRztes);
%             
%             Rztes = [NewFirstRztes'; NewLastRztes'];
%             Iztes = [NewFirstIztes'; NewLastIztes'];
%             fS_new = [NewFirstfS'; NewLastfS'];
%             fS_2 = linspace(fS(1),fS(end),642)';
            indOK = find(imag(ztes)<= 0);
            fS = fS(indOK);
            ztes = ztes(indOK);


            [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@obj.fitZ,p0,fS,...
                [real(ztes) imag(ztes)],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
%             [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@obj.fitZ,p0,fS_new,...
%                 [Rztes Iztes],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
            MSE = (aux2'*aux2)/(length(fS)-length(p)); %#ok<NASGU>
            ci = nlparci(p,aux2,'jacobian',jacob);
            CI = (ci(:,2)-ci(:,1))';  
            p_CI = [p; CI];
            param = obj.GetModelParameters(TES,p_CI,IV,Ib,CondStr);
            fZ = obj.fitZ(p,fS);
%             fZ = obj.fitZ(p,fS_new);
            ERP = sum(abs(abs(ztes-fZ(:,1)+1i*fZ(:,2))./abs(ztes)))/length(ztes);
            R2 = goodnessOfFit(fZ(:,1)+1i*fZ(:,2),ztes,'NRMSE');
%             R2 = goodnessOfFit(fZ(:,1)+1i*fZ(:,2),Rztes + 1i*Iztes,'NRMSE');
            
        end
        
        function fz = fitZ(obj,p,f)
            % Function to fit Z(w) according to the selected
            % electro-thermal model
            
            w = 2*pi*f;
            D = (1+(w.^2)*(p(3).^2));
            switch obj.Zw_Models{obj.Selected_Zw_Models}
                case obj.Zw_Models{1}
                    rfz = p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
                    imz = -(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
                    imz = -abs(imz);
                case obj.Zw_Models{2}
                    fz = p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
                    rfz = real(fz);
                    imz = -abs(imag(fz));
                case obj.Zw_Models{3}
                    fz = p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
                    rfz = real(fz);
                    imz = -abs(imag(fz));
                case obj.Zw_Models{4}
                    %p=[Zinf Z0 tau_I tau_1 tau_2 d1 d2]. Maasilta IH.
                    fz = p(1)+(p(2)-p(1)).*(1-p(6)-p(7)).*(1+1i*w*p(3)-p(6)./(1+1i*w*p(4))-p(7)./(1+1i*w*p(5))).^-1;
                    rfz = real(fz);
                    imz = -abs(imag(fz));
            end
            fz = [rfz imz];
        end
        
        function param = GetModelParameters(obj,TES,p,IVmeasure,Ib,CondStr)
            Rn = eval(['TES.TESParam' CondStr '.Rn.Value;']);
            
%             
            
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
            
            F = TES.circuit.invMin.Value/(TES.circuit.invMf.Value*TES.circuit.Rf.Value);%36.51e-6;
            I0 = IVaux.vout*F;
            Vs = (IVaux.ibias-I0)*TES.circuit.Rsh.Value;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            V0 = Vs-I0*eval(['TES.TESParam' CondStr '.Rpar.Value;']);
            
            P0 = V0.*I0;
            R0 = V0/I0;
            
            param.R0 = R0;
            param.P0 = P0;
            param.Tbath = IVaux.Tbath;
            
            
            param.r0 = R0/Rn;
            param.I0 = I0;
            param.V0 = V0;
%             OP.G0 = OP.C/OP.tau0; 
            % La forma correcta consiste en considerar n y K constantes
            % físicas que se obtienen en el ajuste de P vs T. La
            % propagación para las z(w) dependerá del punto de operación en
            % cada caso. 
            n = eval(['TES.TESThermal' CondStr '.n.Value']);
            K = eval(['TES.TESThermal' CondStr '.K.Value']);
%             eval(['T0 = ((P0./TES.TESThermal' CondStr '.K.Value+Ts.^TES.TESThermal' CondStr '.n.Value)).^(1./(TES.TESThermal' CondStr '.n.Value));']);
            T0 = ((param.P0./K+IVaux.Tbath^n).^(1./n));
%             T0 = ((param.P0/K)+((IVaux.Tbath)^n)/K)^(1/n);
            G0 = n*K*(T0^(n-1));
            param.G0 = G0;
            % Antiguas formas de propagar los valores de T0 y G0.
%             if size(eval(['[TES.Gset' CondStr '.n]']),2) > 1
%                 rp = R0/Rn;
%                 [val, ind] = min(abs(eval(['[TES.Gset' CondStr '.rp]'])-rp));
%                 eval(['T0 = TES.Gset' CondStr '(ind).T_fit;'])   
%                 % Si fijo n, cojo T0 y G0 se toman segun su rp (variables)
% %                 G0 = eval(['TES.TES' CondStr '.G']);  %(W/K)
%                 eval(['G0 = TES.Gset' CondStr '(ind).G;'])   
% %                 param.G0 = TES.TESP.n*TES.TESP.K*T0^(TES.TESP.n-1);
%             else
%                 % Un solo valor de n, K, G y T_fit
%                 T0 = eval(['TES.TESThermal' CondStr '.T_fit.Value;']); %(K)
%                 G0 = eval(['TES.TESThermal' CondStr '.G.Value']);  %(W/K)
%             end            
            
            
            switch obj.Zw_Models{obj.Selected_Zw_Models}
                case obj.Zw_Models{1}
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
                    
                    
                    if TES.TESDim.Abs_bool
                        
                        gammas = [TES.TESDim.Abs_gammaBi.Value TES.TESDim.Abs_gammaAu.Value];
                        rhoAs = [TES.TESDim.Abs_rhoBi.Value TES.TESDim.Abs_rhoAu.Value];                                                
                        param.C_fixed = sum((gammas.*rhoAs).*([TES.TESDim.hMo.Value TES.TESDim.hAu.Value].*TES.TESDim.Abs_width.Value*TES.TESDim.Abs_length.Value).*eval(['TES.TESThermal' CondStr '.T_fit.Value']));
                        param.tau0_fixed = param.C_fixed/G0;
                        param.L0_fixed = (param.tau0_fixed/param.taueff) + 1;
                        param.ai_fixed = param.L0_fixed*G0*T0/P0;
                        
                    else
                        
                    end
                    
                    
                case obj.Zw_Models{2}
                    % hay que definir estos parámetros
                    rp = p(1,:);
                    rp_CI = p(2,:);
%                     rp(1,3) = abs(rp(3));
                    %derived parameters for 2 block model case A
                    param.rp = R0/Rn;
                    param.Zinf = rp(1);
                    param.Zinf_CI = rp_CI(1);
                    param.Z0 = rp(2);
                    param.Z0_CI = rp_CI(2);
                    param.taueff = abs(rp(3));
                    param.taueff_CI = rp_CI(3);
                    param.ca0 = rp(4);
                    param.ca0_CI = rp_CI(4);
                    param.tauA = rp(5);
                    param.tauA_CI = rp_CI(5);
                    
                    param.L0 = (param.Z0-param.Zinf)/(param.Z0+R0);
                    param.L0_CI = sqrt((((param.Zinf+R0)/((param.Z0+R0)^2))*param.Z0_CI)^2 + ((-1/(R0 + param.Z0))*param.Zinf_CI)^2 );
                    
                    param.ai = param.L0*G0*T0/P0;                    
                    param.ai_CI = (G0*T0/P0)*param.L0_CI;
                    
                    param.bi = (param.Zinf/R0)-1;
                    param.bi_CI = (1/R0)*param.Zinf_CI;
                                        
                    param.tau0 = param.taueff*(param.L0-1);
                    param.tau0_CI = sqrt( ((param.L0-1)*param.taueff_CI)^2 + ((param.taueff)*param.L0_CI)^2 );
                   
                    param.C = param.tau0*G0;                    
                    param.C_CI = G0*param.tau0_CI;
                    
                    param.CA = param.C*param.ca0/(1-param.ca0);
                    param.CA_CI = sqrt( (param.ca0/(1-param.ca0)*param.C_CI)^2 + (((param.C*param.ca0)/(param.ca0 - 1)^2 - param.C/(param.ca0 - 1))*param.ca0_CI)^2 );
                    
                    param.GA = param.CA/param.tauA;
                    param.GA_CI = sqrt( ((-param.CA/param.tauA^2)*param.tauA_CI)^2  );                    
                    
                    
                case obj.Zw_Models{3}
                    param = nan;
                case  obj.Zw_Models{4}
                    param = nan;
            end
        end    
                
        function [RES, SimRes, M, Mph, fNoise, SigNoise] = fitNoise(obj,TES,FileName, param, chk)
            % Function for Noise analysis.
            
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:end);
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK');
            Ib = str2double(Name(find(Name == '_', 1, 'last')+1:strfind(Name,'uA.txt')-1))*1e-6;
            if isempty(TES.circuit.CurrOffset.Value)
                TES.circuit.CurrOffset.Value = 0;
            end
            % Buscamos si es Ibias positivos o negativos
            if ~isempty(strfind(Path,'Negative'))
                [~,Tind] = min(abs([TES.IVsetN.Tbath]*1e3-Tbath));
                IV = TES.IVsetN(Tind);
                CondStr = 'N';
%                 OffsetY = TES.IVsetN(1).Offset(1);
        
                Ib = Ib - TES.circuit.CurrOffset.Value;
            else
                [~,Tind] = min(abs([TES.IVsetP.Tbath]*1e3-Tbath));
                IV = TES.IVsetP(Tind);
                CondStr = 'P';
%                 OffsetY = TES.IVsetP(1).Offset(1);
                Ib = Ib - TES.circuit.CurrOffset.Value;
            end
            
            
            noisedata{1} = importdata(FileName);
            fNoise = noisedata{1}(:,1);
            
            SigNoise = TES.V2I(noisedata{1}(:,2)*1e12);
            OP = TES.setTESOPfromIb(Ib,IV,param,CondStr);
%             f = logspace(0,5,1000);
            f = logspace(1,5,321)';
            M = 0;
            
            if length(fNoise) ~= length(f)
                SigNoise = spline(fNoise,SigNoise,f); % Todos los ruidos a 321 puntos                
                fNoise = f;
            end            
            
            SimulatedNoise = obj.noisesim(TES,OP,M,f,CondStr);
            SimRes = SimulatedNoise.Res;            
            
            sIaux = SimulatedNoise.sI;
%             sIaux = ppval(spline(SimulatedNoise.f,SimulatedNoise.sI),fNoise);
            NEP = real(sqrt(((SigNoise*1e-12).^2-SimulatedNoise.squid.^2))./sIaux);            
%             NEP = sqrt(TES.V2I(noisedata{1}(:,2)).^2-SimulatedNoise.squid.^2)./sIaux;
            NEP = NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.
           
            RES = 2.35/sqrt(trapz(noisedata{1}(1:size(NEP,1),1),1./NoiseFiltering(obj,NEP).^2))/2/1.609e-19;
            
            
            findx = find((fNoise > obj.Noise_LowFreq(1) & fNoise < obj.Noise_LowFreq(2)) | (fNoise > obj.Noise_HighFreq(1) & fNoise < obj.Noise_HighFreq(2)));
            xdata = fNoise(findx); 
            
            
            
            if isreal(NEP)
                ydata = NoiseFiltering(obj,NEP*1e18);
%                 ydata = medfilt1(NEP*1e18,obj.DataMedFilt);
%                 findx = find(fNoise > max(obj.Noise_LowFreq,1) & fNoise < obj.Noise_HighFreq);
                if nargin == 5 
                    fig = figure;
                    ax  = axes('Parent',fig');
                    lg = loglog(ax,fNoise,SigNoise);
                    hold on;
                    ax_frame = axis; %axis([XMIN XMAX YMIN YMAX])
%                     delete(ax);
                    axes(ax);
                    rc = rectangle('Position', [obj.Noise_LowFreq(1) ax_frame(3) diff(obj.Noise_LowFreq) ax_frame(4)],'FaceColor',[253 234 23 127.5]/255,'ButtonDownFcn',@rctgle);                                        
                    rc2 = rectangle('Position', [obj.Noise_HighFreq(1) ax_frame(3) diff(obj.Noise_HighFreq) ax_frame(4)],'FaceColor',[214 232 217 127.5]/255,'ButtonDownFcn',@rctgle);                                        
                    pb = uicontrol('style','toggle',...
                        'position',[10 10 180 40],...
                        'fontsize',14,...
                        'string','Done');
                    %                     ax = loglog(fNoise,SigNoise);
                    waitfor(pb,'Value',1);
                    rc_pos = get(rc,'Position');
                    rc2_pos = get(rc2,'Position');
                    close(fig);
                    obj.Noise_LowFreq(1) = rc_pos(1);
                    obj.Noise_LowFreq(2) = rc_pos(1)+rc_pos(3);
                    obj.Noise_HighFreq(1) = rc2_pos(1);
                    obj.Noise_HighFreq(2) = rc2_pos(1)+rc2_pos(3);
%                     findx = find((fNoise > obj.Noise_LowFreq(1) & fNoise < obj.Noise_LowFreq(2)) | (fNoise > obj.Noise_HighFreq(1) & fNoise < obj.Noise_HighFreq(2)));
                end
                  
                ydata = ydata(findx);
                % Proteccion contra ceros
                indceros = find(ydata == 0);
                ydata(indceros) = [];
                xdata(indceros) = [];
                                
                                
                if isempty(findx)||sum(ydata == inf)
                    M = NaN;
                    Mph = NaN;
                else %TES,M,f,OP,CondStr)
                    opts = optimset('Display','off');
                    maux = lsqcurvefit(@(x,xdata) obj.fitjohnson(TES,x,xdata,OP,CondStr),[2 2],xdata,ydata,[],[],opts);   
%                     ans = obj.fitjohnson(TES,[0 0],xdata,OP,CondStr);
%                     figure,loglog(xdata,ydata),hold on, loglog(xdata,ans);
                    M = maux(2);
                    Mph = maux(1);
                    if M <= 0
                        M = NaN;
                    end
                    if Mph <= 0
                        Mph = NaN;
                    end
                end
            else
                M = NaN;
                Mph = NaN;
            end                        
        end
        
        function noise = noisesim(obj,TES,OP,M,f,CondStr)
            % Function for noise simulation.
            %
            % Simulacion de componentes de ruido.
            % de donde salen las distintas componentes de la fig13.24 de la pag.201 de
            % la tesis de maria? ahi estan dadas en pA/rhz.
            % Las ecs 2.31-2.33 de la tesis de Wouter dan nep(f) pero no tienen la
            % dependencia con la freq adecuada. Cuadra mÃ¡s con las ecuaciones 2.25-2.27
            % que de hecho son ruido en corriente.
            % La tesis de Maria hce referencia (p199) al capÃ­tulo de Irwin y Hilton
            % sobre TES en el libro Cryogenic Particle detection. Tanto en ese capÃ­tulo
            % como en el Ch1 de McCammon salen expresiones para las distintas
            % componentes de ruido.
            %
            %definimos unos valores razonables para los parÃ¡metros del sistema e
            %intentamos aplicar las expresiones de las distintas referencias.
            
            gamma = 0.5;            
            C = OP.C;
            L = TES.circuit.L.Value;
%             G = eval(['TES.TES' CondStr '.G;']);
            alfa = OP.ai;
            bI = OP.bi;
            Rn = eval(['TES.TESParam' CondStr '.Rn.Value;']);
            Rs = TES.circuit.Rsh.Value;
            Rpar = eval(['TES.TESParam' CondStr '.Rpar.Value;']);
            RL = Rs+Rpar;
            R0 = OP.R0;
            beta = (R0-Rs)/(R0+Rs);
%             T0 = eval(['TES.TES' CondStr '.T_fit;']);
            Ts = OP.Tbath;
            P0 = OP.P0;
            I0 = OP.I0;
            V0 = OP.V0;
            if size(eval(['[TES.Gset' CondStr '.n]']),2) > 1
                
                
%                 rp = R0/Rn;
%                 [val, ind] = min(abs(eval(['[TES.Gset' CondStr '.rp]'])-rp));
%                 eval(['T0 = TES.Gset' CondStr '(ind).T_fit;'])   
%                 % Si fijo n, cojo T0 y G0 se toman segun su rp (variables)
%                 G = eval(['TES.TESThermal' CondStr '.G.Value']);  %(W/K)
                
                eval(['T0 = ((P0./TES.TESThermal' CondStr '.K.Value+Ts.^TES.TESThermal' CondStr '.n.Value)).^(1./(TES.TESThermal' CondStr '.n.Value));']);
                eval(['G = TES.TESThermal' CondStr '.n.Value*TES.TESThermal' CondStr '.K.Value*T0.^(TES.TESThermal' CondStr '.n.Value-1);']);
%                 eval(['G = TES.Gset' CondStr '(ind).G;'])   
%                 param.G0 = TES.TESP.n*TES.TESP.K*T0^(TES.TESP.n-1);
            else
                % Un solo valor de n, K, G y T_fit
                T0 = eval(['TES.TESThermal' CondStr '.T_fit.Value;']); %(K)
                G = eval(['TES.TESThermal' CondStr '.G.Value']);  %(W/K)
            end           
            
            L0 = P0*alfa/(G*T0);
            %             n = obj.TES.n;
            n = eval(['TES.TESThermal' CondStr '.n.Value;']);
            
            %             if isfield(TES.circuit,'Nsquid')
            %                 Nsquid = TES.circuit.Nsquid.Value;
            %             else
            %                 Nsquid = 3e-12;
            %             end
            
            Nsquid = TES.circuit.Nsquid.Value;
%             if size(Nsquid,1) ~= 1
%                 f = TES.NoiseN.fNoise;
% %                 f = logspace(0,5,1000);
%             else
%                 f = logspace(0,5,1000);
% %                 f = logspace(1,6);
%             end
            if abs(OP.Z0-OP.Zinf) < obj.Z0_Zinf_Thrs
%                 I0 = (Rs/RL)*OP.ibias;
                I0 = sqrt(OP.P0/OP.R0);
            end
%             if C < 0
%                 C = 1e-15;
%             end
                
            tau = C/G;
            taueff = tau/(1+beta*L0);
            tauI = tau/(1-L0);
            tau_el = L/(RL+R0*(1+bI));
            
            if nargin < 3
                M = 0;
                
            end
            
            switch obj.Noise_Models{obj.Selected_Noise_Models}
                case obj.Noise_Models{4} % 'wouter'
                    i_ph = sqrt(4*gamma*obj.Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
                    i_jo = sqrt(4*obj.Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
                    i_sh = sqrt(4*obj.Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
                    noise.ph = i_ph;
                    noise.jo = i_jo;
                    noise.sh = i_sh;
                    noise.sum = sqrt(i_ph.^2+i_jo.^2+i_sh.^2);
                case obj.Noise_Models{1} % 'irwin'
                    try
                        sI = -(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.
                        
                        t = Ts/T0;
                        %%%calculo factor F. See McCammon p11.
                        %n = 3.1;
                        %F = t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n =  exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
                        
                        %                     F = (t^(n+2)+1)/2;%%%specular limit
                        bb = n-1;
                        F=(t^(bb+2)+1)/2;
                        %F = t^(n+1)*(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%F de Mather. La
                        %diferencia entre las dos fÃ³rmulas es menor del 1%.
                        %F = (n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%%%diffusive limit.
                        
                        stfn = 4*obj.Kb*T0^2*G*abs(sI).^2*F;%Thermal Fluctuation Noise
                        ssh = 4*obj.Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
                        %M = 1.8;
                        stes = 4*obj.Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M^2);%%%Johnson noise at TES.
                        if ~isreal(sqrt(stes))
                            stes = zeros(1,length(f));
                        end
                        smax = 4*obj.Kb*T0^2*G.*abs(sI).^2;
                        
                        sfaser = 0;%21/(2*pi^2)*((6.626e-34)^2/(1.602e-19)^2)*(10e-9)*P0/R0^2/(2.25e-8)/(1.38e-23*T0);%%%eq22 faser
                        sext = (18.5e-12*abs(sI)).^2;
                        
                        NEP_tfn = sqrt(stfn)./abs(sI);
                        NEP_ssh = sqrt(ssh)./abs(sI);
                        NEP_tes = sqrt(stes)./abs(sI);
                        Res_tfn = 2.35/sqrt(trapz(f,1./NEP_tfn.^2))/2/1.609e-19;
                        Res_ssh = 2.35/sqrt(trapz(f,1./NEP_ssh.^2))/2/1.609e-19;
                        
                        try
                            Res_tes = 2.35/sqrt(trapz(f,1./NEP_tes.^2))/2/1.609e-19;
                            Res_tfn_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_tfn)))/2/1.609e-19;
                        catch
                            stes = zeros(length(f),1);
                            NEP_tes = sqrt(stes)./abs(sI);
                            Res_tes = 2.35/sqrt(trapz(f,1./NEP_tes.^2))/2/1.609e-19;
                            Res_tfn_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_tfn)))/2/1.609e-19;
                        end
                        
                        Res_tfn_ssh = 2.35/sqrt(trapz(f,1./(NEP_ssh.*NEP_tfn)))/2/1.609e-19;
                        Res_ssh_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_ssh)))/2/1.609e-19;
                        
                        NEP = sqrt(stfn+ssh+stes)./abs(sI);
                        Res = 2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluciÃ³n en eV. Tesis Wouter (2.37).
                        
                        %stes = stes*M^2;
                        i_ph = sqrt(stfn);
                        i_jo = sqrt(stes);
                        if ~isreal(i_jo)
                            i_jo = zeros(1,length(f));
                        end
                        i_sh = sqrt(ssh);
                        %G*5e-8
                        %(n*TES.K*Ts.^n)*5e-6
                        %i_temp = (n*TES.K*Ts.^n)*0e-6*abs(sI);%%%ruido en Tbath.(5e-4 = 200uK, 5e-5 = 20uK, 5e-6 = 2uK)
                        
                        noise.f = f;
                        noise.ph = i_ph;
                        noise.jo = i_jo;
                        noise.sh = i_sh;
                        noise.sum = sqrt(stfn+stes+ssh);%noise.sum = i_ph+i_jo+i_sh;
                        noise.sI = abs(sI);
                        
                        noise.NEP = NEP;
                        noise.max = sqrt(smax);
                        noise.Res = Res;%noise.tbath = i_temp;
                        noise.Res_tfn = Res_tfn;
                        noise.Res_ssh = Res_ssh;
                        noise.Res_tes = Res_tes;
                        noise.Res_tfn_tes = Res_tfn_tes;
                        noise.Res_tfn_ssh = Res_tfn_ssh;
                        noise.Res_ssh_tes = Res_ssh_tes;
                        noise.squid = Nsquid;
                        noise.squidarray = Nsquid.*ones(length(f),1);
                    catch
                        noise.f = f;
                        noise.ph = nan(length(f),1);
                        noise.jo = nan(length(f),1);
                        noise.sh = nan(length(f),1);
                        noise.sum = nan(length(f),1);%noise.sum = i_ph+i_jo+i_sh;
                        noise.sI = nan(length(f),1);
                        noise.squidarray = nan(length(f),1);
                    end
                otherwise
                    warndlg('no valid model',obj.version);
                    noise = [];
            end
        end
        
        function NEP = fitjohnson(obj,TES,M,f,OP,CondStr)
            
            R0=OP.R0;
            Ts = OP.Tbath;
            if size(eval(['[TES.Gset' CondStr '.n]']),2) > 1
%                 rp = R0/eval(['TES.TESParam' CondStr '.Rn.Value']);
%                 [val, ind] = min(abs(eval(['[TES.Gset' CondStr '.rp]'])-rp));
%                 eval(['T0 = TES.Gset' CondStr '(ind).T_fit;'])   
%                 % Si fijo n, cojo T0 y G0 se toman segun su rp (variables)
%                 G = eval(['TES.TESThermal' CondStr '.G.Value']);  %(W/K)
                
                eval(['T0 = ((OP.P0./TES.TESThermal' CondStr '.K.Value+Ts.^TES.TESThermal' CondStr '.n.Value)).^(1./(TES.TESThermal' CondStr '.n.Value));']);
                eval(['G = TES.TESThermal' CondStr '.n.Value*TES.TESThermal' CondStr '.K.Value*T0.^(TES.TESThermal' CondStr '.n.Value-1);']);
%                 eval(['G = TES.Gset' CondStr '(ind).G;'])   
%                 param.G0 = TES.TESP.n*TES.TESP.K*T0^(TES.TESP.n-1);
            else
                % Un solo valor de n, K, G y T_fit
                T0 = eval(['TES.TESThermal' CondStr '.T_fit.Value;']); %(K)
                G = eval(['TES.TESThermal' CondStr '.G.Value']);  %(W/K)
            end          
            
            Circuit = TES.circuit;
            TESThemal = eval(['TES.TESThermal' CondStr ';']);
            TES = eval(['TES.TESParam' CondStr ';']);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             G = TES.G;
%             T0 = TES.T_fit;
            
            Rn = TES.Rn.Value;
            Rpar=TES.Rpar.Value;
            n = TESThemal.n.Value;            
            
            Rs=Circuit.Rsh.Value;            
%             L = 7.7e-8;
            L=Circuit.L.Value;
            
            alfa=OP.ai;
            bI=OP.bi;
            RL=Rs+Rpar;
            
            beta=(R0-Rs)/(R0+Rs);
            %T0=OP.T0;
            Ts=OP.Tbath;
            P0=OP.P0;
            I0=OP.I0;
            V0=OP.V0;            
             
            
            L0=P0*alfa/(G*T0);
            C=OP.C;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            tau=C/G;
            taueff = tau/(1+beta*L0);
            tauI=tau/(1-L0);
            tau_el=L/(RL+R0*(1+bI));
            
            t=Ts/T0;
            F=(t^(n+2)+1)/2;%%%specular limit
            
            sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;
            stfn=4*obj.Kb*T0^2*G*abs(sI).^2*F*(1+M(1)^2);
            stes=4*obj.Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M(2)^2);
            ssh=4*obj.Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
            NEP=1e18*sqrt(stes+stfn+ssh)./abs(sI);
        end
         
        function filtNoise = NoiseFiltering(obj,noisedata)
%             if nargin==1
%                 obj.model='default';
%                 obj.wmed=40;
%             else
%                 obj=varargin{1};
%             end
            
            switch obj.FilterMethods{obj.Selected_FilterMethods}
                case {'default','medfilt'}
                    filtNoise = medfilt1(noisedata,obj.MedFilt);
                case 'nofilt'
                    filtNoise = noisedata;
                case 'minfilt'
                    filtNoise = colfilt(noisedata,[obj.MinWindow 1],'sliding',@min);
                case 'minfilt+medfilt'
                    ydata = colfilt(noisedata,[obj.MinWindow 1],'sliding',@min);
                    filtNoise = medfilt1(ydata,obj.MedFilt);
                case 'movingMean'
                   
                    %%%%Función para aplicar el filtrado de media móvil a unos datos pero
                    %%%%sin afectar al inicio y final de los mismos, reduciendo el tamaño de la
                    %%%%ventana en los extremos.
                    
                    D = ceil(obj.MinWindow-1/2);
                    L = length(noisedata);
                    filtNoise = zeros(L,1);
                    for i = 1:L
                        Mi = min([D,i-1,L-i]);
                        filtNoise(i) = trimmean(noisedata(i-Mi:i+Mi),obj.Perc);%%%media descartando outliers.
                    end
%                     varargout{1}=st;
%                     filtNoise=movingMean(noisedata,obj.wmed);
                case 'quantile'
                    fh = @(data)quantile(data,obj.Perc);
                    filtNoise = colfilt(noisedata,[obj.MedFilt 1],'sliding',fh);                    
            end            
        end
        
        function Plot(obj,fNoise,SigNoise,auxnoise,OP,ax)
            
            switch obj.tipo{obj.Selected_tipo}
                case 'current'
                                                            
                    loglog(ax,fNoise,SigNoise,'.-r','DisplayName','Experimental Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                    hold(ax,'on');
                    grid(ax,'on')
                    loglog(ax,fNoise,obj.NoiseFiltering(SigNoise),'.-k','DisplayName','Exp Filtered Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                    % Añadir color al tramo de señal
                    % utilizado para el ajuste
                    
                    if obj.bool_Mph == 0
                        totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
                    else
                        Mexph = OP.Mph;
                        if isnan(Mexph)
                            Mexph = 0;
                        end
                        totnoise = sqrt((auxnoise.ph.^2.*(1+Mexph^2))+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
%                         totnoise = sqrt(auxnoise.ph.^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                    end
                    if ~obj.bool_components
                        loglog(ax,auxnoise.f,totnoise*1e12,'b','LineWidth',3,'DisplayName','Total Simulation Noise');
                        h = findobj(ax,'Color','b');
                    else                        
                        loglog(ax,auxnoise.f,auxnoise.jo*1e12,'DisplayName','Johnson','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.ph*1e12,'DisplayName','Phonon','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.sh*1e12,'DisplayName','Shunt','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.squidarray*1e12,'DisplayName','Squid','LineWidth',3);
                        loglog(ax,auxnoise.f,totnoise*1e12,'b','DisplayName','Total','LineWidth',3);
                    end
                    ylabel(ax,'pA/Hz^{0.5}');
                case 'nep'
                    
%                     sIaux = ppval(spline(auxnoise.f,auxnoise.sI),fNoise(:,1));
%                     squid = ppval(spline(auxnoise.f,auxnoise.squidarray),fNoise(:,1));
                    sIaux = auxnoise.sI;
                    if length(auxnoise.squidarray) ~= length(auxnoise.sI)
                        auxnoise.squidarray = auxnoise.squidarray';
                    end
                    squid =auxnoise.squidarray;
                    NEP = real(sqrt((SigNoise*1e-12).^2-squid.^2)./sIaux);
                    
                    loglog(ax,fNoise,(NEP*1e18),'.-r','DisplayName','Experimental Noise');hold(ax,'on'),grid(ax,'on'),
                    loglog(ax,fNoise,obj.NoiseFiltering(NEP*1e18),'.-k','DisplayName','Exp Filtered Noise');hold(ax,'on'),grid(ax,'on'),
                    if obj.bool_Mph == 0
                        totNEP = auxnoise.NEP;
                    else
                        Mexph = OP.Mph;
                        if isnan(Mexph)
                            Mexph = 0;
                        end
                        totNEP = sqrt((auxnoise.ph.^2.*(1+Mexph^2))+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2)./auxnoise.sI;
%                         totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
                    end
                    if ~obj.bool_components
                        loglog(ax,auxnoise.f,totNEP*1e18,'b','DisplayName','Total Simulation Noise','LineWidth',3);hold(ax,'on');grid(ax,'on');
                        h = findobj(ax,'Color','b');
                    else                        
                        loglog(ax,auxnoise.f,auxnoise.jo*1e18./auxnoise.sI,'DisplayName','Johnson','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.ph*1e18./auxnoise.sI,'DisplayName','Phonon','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.sh*1e18./auxnoise.sI,'DisplayName','Shunt','LineWidth',3);
                        loglog(ax,auxnoise.f,auxnoise.squidarray*1e18./auxnoise.sI,'DisplayName','Squid','LineWidth',3);
                        loglog(ax,auxnoise.f,totNEP*1e18,'b','DisplayName','Total','LineWidth',3);
                    end
                    ylabel(ax,'aW/Hz^{0.5}');
            end
            axis(ax,[1e1 1e5 2 1e3])
            xlabel(ax,'\nu (Hz)','FontSize',12,'FontWeight','bold')
            title(ax,strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'FontSize',12);
            axis(ax,'tight');
            axes(ax);
            ax_frame = axis; %axis([XMIN XMAX YMIN YMAX])
            rc = rectangle('Position', [obj.Noise_LowFreq(1) ax_frame(3) diff(obj.Noise_LowFreq) ax_frame(4)],'FaceColor',[253 234 23 127.5]/255);
            rc2 = rectangle('Position', [obj.Noise_HighFreq(1) ax_frame(3) diff(obj.Noise_HighFreq) ax_frame(4)],'FaceColor',[214 232 217 127.5]/255);
            
            if abs(OP.Z0-OP.Zinf) < obj.Z0_Zinf_Thrs
                set(get(findobj(ax,'type','axes'),'title'),'Color','r');
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %%%%Pruebas sobre la cotribución de cada frecuencia a la
            %%%%Resolucion.
            if obj.Selected_tipo == 2 % nep
                %                         if strcmpi(obj.NoiseOpt,'nep')
%                 RESJ = sqrt(2*log(2)./trapz(fNoise,1./totNEP.^2));
%                 disp(num2str(RESJ));
%                 semilogx(ax,fNoise(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(fNoise))))/1.609e-19);
%                 hold(ax,'on');
%                 grid(ax,'on');
%                 %                                     RESJ2 = sqrt(2*log(2)./trapz(fNoise(:,1),1./NEP.^2));
%                 %                                     disp(num2str(RESJ2));
%                 semilogx(ax,fNoise(1:end-1),sqrt((2*log(2)./cumsum(1./NEP(1:end-1).^2.*diff(fNoise))))/1.609e-19,'r')
            end
        end
    end
    
    
end

