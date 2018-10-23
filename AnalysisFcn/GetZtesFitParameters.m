function parameters=GetZtesFitParameters(p,OP)
%para modelo de 1 bloque.
%p=[Zinf Z0 taueff]. OP estructura con el pto operacion
parameters.beta=p(1)./OP.R0-1;
parameters.L0=(p(2)-p(1))./(p(2)+OP.R0);
parameters.alfa=parameters.L0.*OP.G0.*OP.T0./OP.P0;
parameters.tau0=(parameters.L0-1).*p(3);
parameters.C0=OP.G0*parameters.tau0;
