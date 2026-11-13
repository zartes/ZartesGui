function param=GetGfromFit(fit,varargin)
%%Devuelve los parámetros termicos a partir de un fit
% param.n=fit.b;
% param.K=-fit.a;
% param.Tc=(fit.c/-fit.a)^(1/fit.b);

% param.n=fit(2);
% param.K=-fit(1);
% param.Tc=(fit(3)/-fit(1))^(1/fit(2));

if nargin==1  %%%usamos modelo por defecto.
     param.n=fit(2);
     param.K=-fit(1);
     param.Tc=(fit(3)/-fit(1))^(1/fit(2));
     param.G=param.n*param.K*param.Tc^(param.n-1);
     param.G0=param.G;
     param.G100=param.n*param.K*0.1^(param.n-1);
elseif nargin==2
    model=varargin{1};
    switch model.nombre
        case 'default'
            param.n=fit(2);
            param.K=-fit(1);
            param.Tc=(fit(3)/-fit(1))^(1/fit(2));
            param.G=param.n*param.K*param.Tc^(param.n-1);
            param.G0=param.G;
            param.G100=param.n*param.K*0.1^(param.n-1);
            if isfield(model,'ci')
                param.Errn=(model.ci(2,2)-model.ci(2,1))/2;%!
                param.ErrK=(model.ci(1,2)-model.ci(1,1))/2;%!
            end
        case 'Tcdirect'
            param.n=fit(2);
            param.K=fit(1);
            param.Tc=fit(3);
            param.G=param.n*param.K*param.Tc^(param.n-1);
            param.G0=param.G;
            param.G100=param.n*param.K*0.1^(param.n-1);
            if isfield(model,'ci')
                param.Errn=(model.ci(2,2)-model.ci(2,1))/2;
                param.ErrK=(model.ci(1,2)-model.ci(1,1))/2;
                param.ErrTc=(model.ci(3,2)-model.ci(3,1))/2;
            end
        case 'GTcdirect'
            param.n=fit(2);
            param.K=fit(1)/(fit(2)*fit(3).^(fit(2)-1));
            param.Tc=fit(3);
            param.G=fit(1);
            param.G0=param.G;
            param.G100=param.n*param.K*0.1^(param.n-1);
            if isfield(model,'ci')
                param.Errn=(model.ci(2,2)-model.ci(2,1))/2;
                param.ErrG=(model.ci(1,2)-model.ci(1,1))/2;
                param.ErrTc=(model.ci(3,2)-model.ci(3,1))/2;
            end
        case 'Ic0'
            param.n=fit(2);
            param.K=-fit(1);
            param.Tc=(fit(3)/-fit(1))^(1/fit(2));
            param.Ic=fit(4);
            %param.Pnoise=fit(5);%%%efecto de posible fuente extra de ruido.
            param.G=param.n*param.K*param.Tc^(param.n-1);
            param.G0=param.G;
            param.G100=param.n*param.K*0.1^(param.n-1);
        case 'T2+T4'
            param.A=fit(1);
            param.B=fit(2);
            param.Tc=fit(3);
            param.G=2*param.Tc.*(param.A+2*param.B*param.Tc.^2);
            param.G0=param.G;
            param.G100=2*0.1.*(param.A+2*param.B*0.1.^2);
        case 'dobleN'
            param.A=fit(1);
            param.B=fit(2);
            param.Tc=fit(3);
            ns=model.Ns;%%%
            param.G=(ns(1)*param.A.*param.Tc.^(ns(1)-1)+ns(2)*param.B.*param.Tc.^(ns(2)-1));
            param.G0=param.G;
            param.G100=(ns(1)*param.A.*(0.1)^(ns(1)-1)+ns(2)*param.B.*(0.1).^(ns(2)-1));
        case 'radiative'
            param.n=4;
            param.K=fit(1);
            param.Tc=fit(2);
            %param.G=fit(1);
            param.G=4*fit(1)*fit(2).^3;
            param.G0=param.G;
            param.G100=4*param.K*0.1^3;
            if isfield(model,'ci')
                %param.Errn=model.ci(2,2)-model.ci(2,1);
                param.ErrK=(model.ci(1,2)-model.ci(1,1))/2;
                param.ErrTc=(model.ci(2,2)-model.ci(2,1))/2;
                param.ErrG=param.G*sqrt((param.ErrK/param.K).^2+3*(param.ErrTc/param.Tc).^2);%!!!
            end
    end
end

% if(0) %%%solo para modelo a T^2+T^4.
%     param.A=fit(1);
%     param.B=fit(2);
%     param.Tc2=fit(3);
%     param.G2=2*param.Tc2.*(param.A+2*param.B*param.Tc2.^2);
%     param.G2_100=2*0.1.*(param.A+2*param.B*0.1.^2);
% end
