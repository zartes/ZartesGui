function model=BuildPTbModel(varargin)
%%%Modelos: 'default', 'Tcdirect', 'GTcdirect', 'Ic0', 'T2+T4'.
%%%
if nargin>0
    if ischar(varargin{1})
        name=varargin{1};
    elseif isstruct(varargin{1})
        name=varargin{1}.nombre;
    end
end
if nargin==0
    model.nombre='default';
    model.function=@(p,T)(p(1)*T.^p(2)+p(3));
    model.description='p(1)=-K p(2)=n p(3)=P0=k*Tc^n'
    model.X0=[-50 3 1];
    model.LB=[-Inf 2 0];%%%lower bounds
    model.UB=[];%%%upper bounds
else %if ischar(varargin{1})
    switch name
        case 'Tcdirect'
            model.nombre='Tcdirect';
            model.function=@(p,T)(p(1)*(p(3).^p(2)-T.^p(2)));
            model.description='p(1)=K p(2)=n p(3)=Tc'
            model.X0=[50 3 0.1];
            model.LB=[0 2 0];%%%lower bounds
            model.UB=[];%%%upper bounds
        case 'GTcdirect'
            model.nombre='GTcdirect';
            model.function=@(p,T)(p(1)*(p(3).^p(2)-T.^p(2))./(p(2).*p(3).^(p(2)-1)));
            model.description='p(1)=G0 p(2)=n p(3)=Tc'
            model.X0=[100 3 0.1];
            model.LB=[0 2 0];%%%lower bounds
            model.UB=[];%%%upper bounds
        case 'Ic0'
            model.nombre='Ic0';
            model.function=@(p,T)(p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3));%+p(5);
            model.description='p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0'
            model.X0=[-6500 3.03 13 1.9e4]; 
            model.LB=[-1e5 2 0 0];
            model.UB=[];
        case 'T2+T4'
            model.nombre='T2+T4';
            model.function=@(p,T)(p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4));
            model.description='p(1)=A, p(2)=B, p(3)=Tc'
            model.X0=[1 1 0.1]; 
            model.LB=[0 0 0];
            model.UB=[];
        case 'dobleN'
            model.nombre='dobleN';
            if isfield(varargin{1},'Ns')
                model.Ns=varargin{1}.Ns;
            else
                %model.Ns=[4 3];%intento de generalizar ley doble N.
                model.Ns=[1 4];%[1 4] para difusivo+radiativo.
            end
            ns=model.Ns;
            model.function=@(p,T)(p(1)*(p(3)^ns(1)-T.^ns(1))+p(2)*(p(3)^ns(2)-T.^ns(2)));
            model.description='p(1)=A, p(2)=B, p(3)=Tc'
            model.X0=[5e4 0.5e3 0.1];
            model.LB=[0 0 0];
            model.UB=[];
        case 'radiative'
            model.nombre='radiative';
            model.function=@(p,T)p(1)*(p(2)^4-T.^4);
            model.description='p(1)=K, p(2)=Tc'
            model.X0=[1e4 0.1]; %data is in pW.
            model.LB=[0 0];
            model.UB=[];
    end
end