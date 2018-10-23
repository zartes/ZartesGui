function param = GetGfromFit(fit)
%%Devuelve los parámetros termicos a partir de un fit
% param.n=fit.b;
% param.K=-fit.a;
% param.Tc=(fit.c/-fit.a)^(1/fit.b);

param.n = fit(2);
param.K = -fit(1);
param.Tc = (fit(3)/-fit(1))^(1/fit(2));
if length(fit) > 3
    param.Ic = fit(4);%%%used in model2
    %param.Pnoise=fit(5);%%%efecto de posible fuente extra de ruido.
end

param.G = param.n*param.K*param.Tc^(param.n-1);
% param.G100 = param.n*param.K*0.1^(param.n-1);%%%Añadimos la G a una temperatura concreta, 100mK para poder comparar distintos TES.
