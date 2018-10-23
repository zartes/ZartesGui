function imz=fitImZ(p,f)
%% Función compañera de fitZ que sólo ajusta la parte imaginaria.
%Pasamos de [p(1) p(2) p(3)]=[Zinf Z0 tau_eff] -> a [p(1) p(2)]=[Zinf-Z0 tau_eff]
w=2*pi*f;
D=(1+(w.^2)*(p(2).^2));
%fz=p(1)-(p(2)+p(1))./(-1+2*pi*f*p(3)*1i);

imz=-p(1)*w*p(2)./D;