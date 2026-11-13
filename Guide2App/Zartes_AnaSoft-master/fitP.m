function P=fitP(p,T,model)
%expression used to automatically fit P(Tbath) data.

[ii,jj]=size(T);
%model=1;%%%ii;
if isnumeric(model) %%%Vieja definicion de model como numero.
    if model==0 %%%ojo, esto es enrevesado
        P=p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4);%%%modelo de Wang AIP 1219 75 (2010).
    elseif model==1
        %%%p(1)=a=-K, p(2)=n, p(3)=P0=K*Tc^n
        %P=p(1)*T.^p(2)+p(3);
        
        %%%%Direct Tc fit p(1)=K, p(2)=n, p(3)=Tc
        P=p(1).*(p(3).^p(2)-T.^p(2));
    elseif model==2
        %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0. p(5)=Pnoise
        P=p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3);%+p(5);
    elseif model>2
        error('wrong P(T) model?')
    end
elseif isstruct(model)
    f=model.function;
    P=f(p,T);
end