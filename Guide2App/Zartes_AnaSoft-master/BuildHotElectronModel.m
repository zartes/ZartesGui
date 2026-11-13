function sys=BuildHotElectronModel(Circuit,OP)
%Galeazzi describe muy bien los distintos modelos, pero en el Hot Electron
%hay que usar la Telectron. Es conocida? Es válido usar T0 para todo cuando
%precisamente el modelo asume que Tph!=Te? Galeazzi supone además que W se
%mete directamente a los phonones (absorcion radiacion). Para nuestras
%medidas Z(w) en realidad la W seria la Pjoule, que esta asociada a los
%electrones (o no?).

%parametros del circuito
Rsh=Circuit.Rsh;
Rpar=Circuit.Rpar;
L=Circuit.L;

%parámetros del punto de operación
R0=OP.R0;
I0=OP.I0;
P0=OP.P0;
T0=OP.T0;

G=OP.G0;
C=OP.C0;
ai=OP.ai;
bi=OP.bi;
L0=OP.L0;