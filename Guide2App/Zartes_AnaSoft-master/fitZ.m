function fz=fitZ(p,f)
%ajusta los datos de Z al modelo de la funcion Z()
%Se pasa un vector 'p' de 3 parametros y el vector de frecuencias.
%Se puede definir la expresión de varias maneras y el significado de 'p'
%será diferente. Comencé con una más compleja y la última usa directamente
%Z0, Zinf y Tau.
%La expresion es A+B*(1+w*tau*i)/(-1+w*tau*i). A y B están relacionados con
%Zinf y Z0.
%Para hacer el ajuste a los datos basta ejecutar:
%[p,aux1,aux2,aux3,out]=lsqcurvefit(@fitZ,p0,f,z2);
%donde p0 es una estimación inicial de los parámetros 
%(importante pasar valores cercanos a los esperados) y z2 tiene las mismas
%dimensiones que fz (es decir, se separan las parte real e imaginaria de los
%datos). Otra opción es que fz devuelva valorse complejos y a 'lsqcurvefit'
%pasarle 'z', los datos complejos de impedancia. 
%El resultado del ajuste se devuelve en 'p'. En el segundo caso es un
%vector comlpejo, pero debe salir una parte imaginaria despreciable.

%Para usar un modelo más complejo basta cambiar la definición de fz y usar
%una definición adecuada de 'p'.

%Z=fittype('R0*((1+bi)+(1+bi/2)*(I0^2*R0*ai*tau/(C*T))*(-1+((1+i*2*pi.*f*tau)./(-1+i*2*pi*f*tau))))','independent','f');
%fz=fit(logspace(0,6)',zdata',Z);

%fz(1,:)=real(p(1)+p(2)*((1+2*pi*p(3)*f*i)./(-1+2*pi*p(3)*f*i)));
%fz(2,:)=imag(p(1)+p(2)*((1+2*pi*p(3)*f*i)./(-1+2*pi*p(3)*f*i)));

%fz=p(1)+p(2)*((1+2*pi*p(3)*f*i)./(-1+2*pi*p(3)*f*i));

%alternative definition ztes=Zinf-(Z0-Zinf)/(-1+w*tau*i)
%pasamos directamente Zinf=p(1), Z0=p(2), tau=p(3).
%manejamos magnitudes complejas directamente.

w=2*pi*f;
D=(1+(w.^2)*(p(3).^2));
%fz=p(1)-(p(2)+p(1))./(-1+2*pi*f*p(3)*1i);
%rfz=real(fz);imz=imag(fz);

%modelo='2b';
%if strcmp(modelo,'1b')

if length(p)==3
    %%%p=[Zinf Z0 tau];
    rfz=p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
    imz=-(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
    imz=-abs(imz);
%elseif strcmp(modelo,'2b')

elseif length(p)==4 %%%1TB mas reactancia Ztes_tot=ZTES//iwLt
    %%%p=[Zinf Z0 tau Lt];
    fz=p(1)-(p(1)-p(2))./(1-1i*w*p(3));
    fz=(fz.^-1+(1i*w*p(4)).^-1).^-1;
    %fz=fz+(1i*w*p(4));%%%Lj en serie.
    rfz=real(fz);
    imz=-abs(imag(fz));
elseif length(p)==5
    %p=[Zinf Z0 tau_eff c tau_A]; c=CA/C0, tauA=CA/Gtes.
%     rfz=p(1)-(p(1)-p(2))./D+(p(4)-p(5))*w*p(3)./D;%%%modelo de 2bloques.
%     imz=p(4)-(p(1)-p(2))*w*p(3)./D-(p(4)-p(5))./D;%%%modelos de 2 bloques.
    
%     %p=[Zinf Z0 tau_I d1 tau1]; *tau_I=Ctes/(Gtes+G)(LH-1),  *d=Gtes/(Gtes+G)(LH-1), tau1=CA/Gtes
     fz=p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;%%%Maasilta.!!!
     %%%!!!<-1-feb-2019. Tengo que redefinir la ecuación porque con esa
     %%%definición de p(4) en la ec debe ir con un signo '+'.
     %fz=p(1)+p(2).*(1-1i*w*p(3)-p(4)./(1+1i*w*p(5))).^-1;%%%Maasilta simplified parameter definition.
     %p=[Zinf Z0 tau_eff c tau_A]; c=CA/C0, tauA=CA/Gtes.
     %fz=p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
     %fz=p(1)+(p(2)-p(1)).*(1-1i*w*p(3)+p(4)./(1+1i*w*p(5))).^-1;%%%TFG_Marc
     rfz=real(fz);
     imz=imag(fz);
     %imz=-abs(imag(fz));
elseif length(p)==7
    %p=[Zinf Z0 tau_I tau_1 tau_2 d1 d2]. Maasilta IH.
    fz=p(1)+(p(2)-p(1)).*(1-p(6)-p(7)).*(1+1i*w*p(3)-p(6)./(1+1i*w*p(4))-p(7)./(1+1i*w*p(5))).^-1;
    rfz=real(fz);
    imz=-abs(imag(fz));
end
%fz=rfz+1i*imz;%%%uncomment for complex parameters.
if iscolumn(rfz)
    fz=[rfz imz];%%%uncomment for real parameters.
else
    fz=[rfz' imz'];%%%uncomment for real parameters.
end

%%%para ajustar 1/fZ.try1.
%ifz=1./fz;
%ifz=[real(ifz) imag(ifz)];

%%%p=[Zinf 1/Z0 1/taueff]. Intento de ajustar a 1/Ztes.
% ifz=p(2)*(-p(3)+1i*w)./(-p(3)+1i*w*p(1)*p(2));
% %rifz=real(ifz);
% %imifz=imag(ifz);
% D=p(3).^2+w.^2.*p(1).^2.*p(2).^2;
% rifz=p(2)*(p(3).^2+w.^2.*p(1).*p(2))./D;
% imifz=p(2).*w.*p(3)*(p(1).*p(2)-1)./D;
% ifz=[rifz -imifz];%?

%modelo 2 bloques Caso A cuadernos maria.ec(70)section 4.4.1.
%incluyo dos parámetros mas, el cociente de capacidades y un tau_A
%p=[Zinf Z0 tau_eff c tau_A]; c=CA/C0, tauA=CA/Gtes.
%El caso B es igual, solo que los parámetros tienen una interpretacion
%diferente.
%
% fz=p(1)+(p(1)-p(2))./(-1+2*pi*f*p(3)*1i.*(1-p(4)*(2*pi*f*p(5)*1i)./(1+2*pi*f*p(5)*1i)));
% rfz=real(fz);imz=imag(fz);
% fz=[rfz imz];