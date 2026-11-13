function V=Fit_V_Delta(p,t)
%%%Función para ajustar la respuesta de un sistema a dos exponenciales.
%%% p=[A tau1 tau2 t0] p0=[-2.5 5e-6 0.8e-7 9e-6];

V=p(1)*heaviside(t-p(4)).*(exp(-(t-p(4))/p(2))-exp(-(t-p(4))/p(3)));