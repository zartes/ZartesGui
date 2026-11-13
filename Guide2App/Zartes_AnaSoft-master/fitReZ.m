function rfz=fitReZ(p,f)
%% Función compañera de fitZ para ajustar solo parte Real
%cambiamos a mano tau_eff a partir del ajuste de parte imaginaria y el
%parámetro A. pasamos sólo p(1)=Zinf. o no se pasa A y se pasa Zinf y Z0.

%tau_eff=1.7396e-4;
%A=19.19974e-3;%A=Zinf-Z0
w=2*pi*f;
%D=(1+(w.^2)*(tau_eff.^2));
D=(1+(w.^2)*(p(3).^2));
%fz=p(1)-(p(2)+p(1))./(-1+2*pi*f*p(3)*1i);

rfz=p(1)-(p(1)-p(2))./D;