function [TF,p]=BuildLinearModel(Circuit,OP)
%%%creamos un modelo matlab con las ecuaciones linealizadas de los TES.
%%set1:G=1.7e-12;C=2.3e-15;I0=1e-6;L=400e-9;R0=80e-3;T0=.150;alfa=100;bi=0.96;

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
C=OP.C;
ai=OP.ai;
bi=OP.bi;
L0=OP.L0;

%deduced param
L0=P0*ai/(G*T0); % low freq loop gain.
%tau=1/(I0^2*R0*ai/(C*T)-G/C) %constante de tiempo efectiva

tau0=C/G;
tau_i=tau0/(L0-1);
tau_el=L/(Rsh+Rpar+R0*(1+bi));

%-A.ojo a los signos. ec(19)Irwin Book.Tb Ch4 tesis lindeman.
A(1,1)=-1/tau_el;
A(1,2)=-L0*G/(I0*L); %A
A(2,1)=I0*R0*(2+bi)/C; %B
A(2,2)=1/tau_i;

tauetc=sqrt(abs(A(1,2)*A(2,1)))^-1;
%tau_el,tau_i,
%sqrt(tau_el*tau_i),1/(1/tau_el+1/tau_i)

%%%Parameters for time response:
dA=det(A);
trA=trace(A);
i_inf=-A(2,2)/dA;
splus=(trA+sqrt(trA^2-4*dA))/2;
sminus=(trA-sqrt(trA^2-4*dA))/2;
a0=trA-1/i_inf+splus;
s_dif=splus-sminus;

p=[i_inf a0/s_dif 1/splus 1/sminus];

%%%system definition.%%% 3 equivalent methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%por bloques.
%tf1=tf({1 0;0 1},{[1 0] 1;1 [1 0]});%I*1/s
%%%%tf2=tf({A(1,1) A(1,2);A(2,1) A(2,2)},1);
%TF=feedback(tf1,A);

%direct
%%%den=[1 A(1,1)+A(2,2) A(1,1)*A(2,2)-A(1,2)*A(2,1)];%use det(A),tr(A)
%den=[1 trace(A) det(A)];
%TF=tf({[1 A(2,2)] -A(1,2);-A(2,1) [1 A(1,1)]},den)

%matrix algebra
s=tf('s');
TF=1/(s*eye(2)-A);