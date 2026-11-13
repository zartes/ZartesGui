function model=BuildThermalModel(varargin)
%%%%Construimos un modelo para el Fit de las Z(w).

opt=[];
for i=1:nargin
    %varargin{i}
    if ischar(varargin{i}) name=varargin{i}; end
    if isstruct(varargin{i}) opt=varargin{i}; end
end

if nargin==0
    model.nombre='default';
    model.function=@(p,f)([p(1)-(p(1)-p(2))./(1+((2*pi*f).^2)*(p(3).^2)) ...
      -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
    model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1-1i*(2*pi*f)*p(3)).^-1);

       %%%model.function=@(p,f)([ ... %%%%modelo para ajustar sólo Imag(Z).
      %%%-abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
    
      %w=2*pi*f;
    %D=(1+((2*pi*f).^2)*(p(3).^2));
    %rfz=p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
    %imz=-(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
    %imz=-abs(imz);
    
    model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff';
    model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
    model.LB=[-Inf -Inf 0];%%%lower bounds
    model.UB=[];%%%upper bounds    
    model.noise=noisesim('irwin');%%%Ojo, noise model con default parameters
else
    switch name
        case 'default'
                model.nombre='default';
                model.function=@(p,f)([p(1)-(p(1)-p(2))./(1+((2*pi*f).^2)*(p(3).^2)) ...
                    -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
                
                model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1-1i*(2*pi*f)*p(3)).^-1);
                model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff';
                model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
                model.LB=[-Inf -Inf 0];%%%lower bounds
                model.UB=[];%%%upper bounds
                if isempty(opt)
                    model.noise=noisesim('irwin');
                else
                    model.noise=noisesim('irwin',opt.TES,opt.OP,opt.circuit);
                end
            
        case 'ImZ'
            model.nombre='ImZ';
            model.function=@(p,f)([ ... %%%%modelo para ajustar sólo Imag(Z).
                -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
            model.description='p(1)=Zinf p(2)=Z0 p(3)=taueff';
            model.X0=[-1e-2 1e-2 1e-6];%%%p0=[Zinf Z0 tau0];%%%1TB
            model.LB=[-Inf -Inf 0];%%%lower bounds
            model.UB=[];%%%upper bounds
                if isempty(opt)
                    model.noise=noisesim('irwin');
                else
                    model.noise=noisesim('irwin',opt.TES,opt.OP,opt.circuit);
                end
        case '2TB_hanging'
            model.nombre='2TB_hanging';
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1);
            model.description='p=[Zinf Z0 tau_I d1 tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *d=Gtes/(Gtes+G)(LH-1), tau1=CA/Gtes';
            model.X0=[1e-2 -1e-2 1/(2*pi*1e4) 100 1/(2*pi*1e2)];
            model.LB=[0 -Inf -Inf -Inf 0];
            model.UB=[Inf Inf Inf Inf 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_hanging',opt.TES,opt.OP,opt.circuit);
                end
        case '2TB_hanging_Lh-a'
            model.nombre='2TB_hanging_Lh-a';
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)*p(1))./(1-p(2)).*(1-1i*(2*pi*f)*p(3)-(p(4)./(1-p(2)))./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)*p(1))./(1-p(2)).*(1-1i*(2*pi*f)*p(3)-(p(4)./(1-p(2)))./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.Cfunction=@(p,f)(p(1)+(p(2)*p(1))./(1-p(2)).*(1-1i*(2*pi*f)*p(3)-(p(4)./(1-p(2)))./(1+1i*(2*pi*f)*p(5))).^-1);%%%funcion que devuelve complejo.
            model.description='p=[Zinf LH tau_I a tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *a=Gtes/(Gtes+G), tau1=CA/Gtes';
            L0=1;a=0.5;cc=10;LH0=L0/(1-a);
            tau0=1e-3; tauI0=tau0*(1-a)^2/(L0-1-a); 
            %tau1_0=cc*tauI0*(LH0-1)/a;%%Esta def debería ser válida, pero
            %conduce a sign(tau1)=sign(tauI), pero tau1>0.
            tau1_0=cc*tau0*(1-a)/a;
            model.X0=[0.005 LH0 tauI0 a tau1_0];%%%Ojo a inicializar p(2)=Lh=1, da Inf.
            %model.X0=[0.0085 0.9329 -2e-4 0.5 0.0022];%%%p0(40%)
            %model.X0=[0.0120 0.2214 -3.3686e-05 0.6697 0.0030];%%%p0(75%)
            model.LB=[-Inf 0 -Inf 0 0];
            model.UB=[Inf Inf 1 1 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_hanging',opt.TES,opt.OP,opt.circuit);
                end
        case '2TB_intermediate'
            model.nombre='2TB_intermediate';
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1);
            model.description='p=[Zinf Z0 tau_I d1 tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *d=Gtes/(Gtes+G)(LH-1), tau1=CA/Gtes';
            model.X0=[1e-2 -1e-2 1/(2*pi*1e4) 0.03 1/(2*pi*1e2)];
            model.LB=[0 -Inf -Inf -Inf 0];
            model.UB=[Inf Inf Inf Inf 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_intermediate',opt.TES,opt.OP,opt.circuit);
                end
                
        case '2TB_parallel'
            model.nombre='2TB_parallel';
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
            model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1);
            model.description='p=[Zinf Z0 tau_I geff/(Lp-1) tau1]; *tau_I=Ctes/(Gtes,1+Gtes,b)(Lp-1),  geff=Gt,1(T0)*Gt,1(T1)/((Gt,1+Gt,b)*(T0->T1)), tau1=C1/(gt,1(T0)+gt,b)';
            model.X0=[1e-2 -1e-2 1/(2*pi*1e4) 0.03 1/(2*pi*1e2)];
            model.LB=[0 -Inf -Inf -Inf 0];
            model.UB=[Inf Inf Inf Inf 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('2TB_parallel',opt.TES,opt.OP,opt.circuit);
                end
                
        case '3TB_general'
            model.nombre='3TB';
            %fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;
            model.function=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)+p(6)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))+p(6)./(1+1i*(2*pi*f)*p(7))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))+p(6)./(1+1i*(2*pi*f)*p(7))).^-1)];
            model.Cfunction=@(p,f)(p(1)+(p(2)-p(1)).*(1+p(4)+p(6)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))+p(6)./(1+1i*(2*pi*f)*p(7))).^-1);
            model.description='p=[Zinf Z0 tau_I K1 tau1 K2 tau2]'; 
            a1=0.9;a2=0.1;L=0.2;tau0=4.5e-5;tau1=20*5e-5;tau2=40e-5;
            %model.X0=[1e-2 -1e-2 1/(2*pi*1e4) 0.03 1/(2*pi*1e2) 0.1 1/(2*pi*1e6)];
            K1=a1/(L-1);K2=a2/(L-1);tI0=tau0/(L-1);
            model.X0=[1e-2 -1e-2 tI0 K1 tau1 K2 tau2];
            if sign(L-1)>0 lb=0;ub=Inf; else lb=-Inf;ub=0;end
            model.LB=[0 -Inf lb lb 0 lb 0];
            model.UB=[Inf Inf ub ub 1 ub 1];
                if isempty(opt)
                    model.noise=noisesim('irwin');%%%!!!ojo, noise model con default options
                else
                    model.noise=noisesim('3TB',opt.TES,opt.OP,opt.circuit);%%%Falta implementar modelo ruido.
                end
    end
end

