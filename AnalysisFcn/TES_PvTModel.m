classdef TES_PvTModel
    % Class TF for TES data
    %   This class contains options for Z(W) analysis
    
    properties              
        Models = {'G0nT_fit_direct';'KnT_fit_direct';'KnP0_direct';'KnP0Ic0_direct';'ABT_fit_direct';'Kn_direct'}; % One Single Thermal Block, Two Thermal Blocks
        Selected_Models = 1;
        
        Function = [];
        Description = [];
        X0 = [];%%%initial values
        LB = [];%%%lower bounds
        UB = [];%%%upper bounds
                
    end
    
    methods
        
        function obj = Constructor(obj)
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2))./(p(2).*p(3).^(p(2)-1)));
                    obj.Description = 'p(1)=G0 p(2)=n p(3)=T_fit';          % 3 parameters
                    obj.X0 = [100 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{2}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2)));
                    obj.Description = 'p(1)=K p(2)=n p(3)=T_fit';
                    obj.X0 = [50 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{3}
                    obj.Function = @(p,T)(p(1)*T.^p(2)+p(3));
                    obj.Description = 'p(1)=-K p(2)=n p(3)=P0=k*T_fit^n';
                    obj.X0 = [-50 3 1];
                    obj.LB = [-Inf 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{4}
                    obj.Function = @(p,T)(p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3));
                    obj.Description = 'p(1)=-K, p(2)=n, p(3)=P0=K*T_fit^n, p(4)=Ic0';
                    obj.X0 = [-6500 3.03 13 1.9e4];
                    obj.LB = [-1e5 2 0 0];
                    obj.UB = [];
                case obj.Models{5}
                    obj.Function = @(p,T)(p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4));
                    obj.Description = 'p(1)=A, p(2)=B, p(3)=T_fit';
                    obj.X0 = [1 1 0.1];
                    obj.LB = [0 0 0];
                    obj.UB = [];
                case obj.Models{6}
                    obj.Function = @(p,T,T_fit)(p(1)*(T_fit.^p(2)-T.^p(2))./(p(2).*T_fit.^(p(2)-1)));
                    obj.Description = 'p(1)=K p(2)=n';      
                    obj.X0 = [50 3];
                    obj.LB = [0 2];%%%lower bounds
                    obj.UB = [];
            end
        end
        
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_PvTModel');
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
        
        function obj = BuildPTbModel(obj)
            
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2))./(p(2).*p(3).^(p(2)-1)));
                    obj.Description = 'p(1)=G0 p(2)=n p(3)=T_fit';          % 3 parameters
                    obj.X0 = [100 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{2}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2)));
                    obj.Description = 'p(1)=K p(2)=n p(3)=T_fit';
                    obj.X0 = [50 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{3}
                    obj.Function = @(p,T)(p(1)*T.^p(2)+p(3));
                    obj.Description = 'p(1)=-K p(2)=n p(3)=P0=k*T_fit^n';
                    obj.X0 = [-50 3 1];
                    obj.LB = [-Inf 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{4}
                    obj.Function = @(p,T)(p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3));
                    obj.Description = 'p(1)=-K, p(2)=n, p(3)=P0=K*T_fit^n, p(4)=Ic0';
                    obj.X0 = [-6500 3.03 13 1.9e4];
                    obj.LB = [-1e5 2 0 0];
                    obj.UB = [];
                case obj.Models{5}
                    obj.Function = @(p,T)(p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4));
                    obj.Description = 'p(1)=A, p(2)=B, p(3)=T_fit';
                    obj.X0 = [1 1 0.1];
                    obj.LB = [0 0 0];
                    obj.UB = [];
                case obj.Models{6}
                    obj.Function = @(p,T,T_fit)(p(1)*(T_fit.^p(2)-T.^p(2))./(p(2).*T_fit.^(p(2)-1)));
                    obj.Description = 'p(1)=K p(2)=n';
                    obj.X0 = [50 3];
                    obj.LB = [0 2];%%%lower bounds
                    obj.UB = [];
            end                                    
        end
        
        function P = fitP(obj,p,T,T_fit)
            % Function to fit P(Tbath) data.
            
            f = obj.Function;
            switch obj.Models{obj.Selected_Models}
                case obj.Models{6}
                    P = f(p,T,T_fit);
                otherwise
                    P = obj.Function(p,T);
            end
        end
        
        function param = GetGfromFit(obj,fit)
            % Function to get thermal parameters from fitting
            
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = fit(1,1);
                    param.G_CI = fit(1,2);
                    param.K = param.G/(param.n*param.T_fit.^(param.n-1));
                    param.K_CI = sqrt( ((param.T_fit^(1 - param.n)/param.n)*param.G_CI)^2 + ...
                        ((-(param.G*(param.n - 1))/(param.T_fit^param.n*param.n))*param.T_fit_CI)^2 + ...
                        ((- (param.G*param.T_fit^(1 - param.n))/param.n^2 - (param.G*param.T_fit^(1 - param.n)*log(param.T_fit))/param.n)*param.n_CI)^2); % To be computed
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrG = model.ci(1,2)-model.ci(1,1);
%                         param.ErrT_fit = model.ci(3,2)-model.ci(3,1);
%                     end
                case obj.Models{2}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = fit(1);
                    param.K_CI = fit(1,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrK = model.ci(1,2)-model.ci(1,1);
%                         param.ErrT_fit = model.ci(3,2)-model.ci(3,1);
%                     end
                    
                case obj.Models{3}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = -fit(1,1);
                    param.K_CI = abs(fit(1,2));
                    param.P0 = fit(3,1);
                    param.P0_CI = fit(3,2);
                    
                    param.T_fit = (param.P0/param.K)^(1/param.n);
                    param.T_fit_CI = sqrt( (((param.P0*(-param.P0/param.K)^(1/param.n - 1))/(param.K^2*param.n))*param.K_CI)^2 ...
                        + ((-(log(-param.P0/param.K)*(-param.P0/param.K)^(1/param.n))/param.n^2)*param.n_CI)^2 ...
                        + ((-(-param.P0/param.K)^(1/param.n - 1)/(param.K*param.n))*param.P0_CI)^2);
                    
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrK = model.ci(1,2)-model.ci(1,1);
%                     end
%                     
                case obj.Models{4}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = -fit(1,1);
                    param.K_CI = fit(1,2);
                    param.P0 = fit(3,1);
                    param.P0_CI = fit(3,2);
                    
                    param.T_fit = (param.P0/param.K)^(1/param.n);
                    param.T_fit_CI = sqrt( (((param.P0*(-param.P0/param.K)^(1/param.n - 1))/(param.K^2*param.n))*param.K_CI)^2 ...
                        + ((-(log(-param.P0/param.K)*(-param.P0/param.K)^(1/param.n))/param.n^2)*param.n_CI)^2 ...
                        + ((-(-param.P0/param.K)^(1/param.n - 1)/(param.K*param.n))*param.P0_CI)^2);
                    
                    param.Ic = fit(4,1);
                    param.Ic_CI = fit(4,2);
                    %param.Pnoise=fit(5);%%%efecto de posible fuente extra de ruido.
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
                    
                case obj.Models{5}
                    param.A = fit(1,1);
                    param.A_CI = fit(1,2);
                    param.B = fit(2,1);
                    param.B_CI = fit(2,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = 2*param.T_fit.*(param.A+2*param.B*param.T_fit.^2);
                    param.G_CI = sqrt( ((12*param.B*param.T_fit^2 + 2*param.A)*param.T_fit_CI)^2 + ...
                        ((2*param.T_fit)*param.A_CI)^2 + ...
                        ((4*param.T_fit^3)*param.B_CI)^2 );  %To be computed
                    param.G0 = param.G;
                    param.G_100 = 2*0.1.*(param.A+2*param.B*0.1.^2);
                    
                case obj.Models{6}                    
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = fit(1,1);
                    param.K_CI = fit(1,2);
                    param.T_fit = obj.TESP.T_fit;
                    param.T_fit_CI = 0;
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
                    
            end
            
        end
        
        
    end
end