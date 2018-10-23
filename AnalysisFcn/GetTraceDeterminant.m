function Out=GetTraceDeterminant(P,TES,circuit)
%%%Función para calcular la traza y el determinante de la matriz para un
%%%punto de operación determinado.

L=circuit.L;
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;

for i=1:length(P)
    ai=P(i).ai;
    bi=P(i).bi;
    T0=TES.Tc;
    R0=P(i).rp*TES.Rn;
    L0=P(i).L0;
    tau0=P(i).tau0;
    C=P(i).C;
    G=C/tau0;
    I0=sqrt(L0*G*T0/(R0*ai));%%%Para no pasar la IV recalculamos I0 a partir de L0 y P0.
    %deduced param
    %L0=P0*ai/(G*T0); % low freq loop gain.
    %tau=1/(I0^2*R0*ai/(C*T)-G/C) %constante de tiempo efectiva
    
    %tau0=C/G;
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
    Out(i).dA=det(A);
    Out(i).trA=trace(A);
end


