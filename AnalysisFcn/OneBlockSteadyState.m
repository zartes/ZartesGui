function [X,Y]=OneBlockSteadyState(circuit,TES,Tbath)
%%%%Otro intento de resolver las ecuacione electrotérmicas 

RL=circuit.Rsh+circuit.Rpar;
n=TES.n;
Tc=TES.Tc;

a=TES.Ic*RL;
b=TES.Ic*TES.Rn;
c=b*TES.Ic;
d=TES.K*TES.Tc^TES.n;


%Ib=0:500e-6;
Ib=10e-6:10e-6:500e-6;
%Ib=300e-6;
Ib=500e-6:-10e-6:10e-6;
%Tbath=0.10;

V0=Ib*circuit.Rsh;
t0=Tbath/Tc;
x=0.3:1e-4:1.0;
for i=1:length(V0)
    Y1=0.5*(V0(i)/a+sqrt((V0(i)/a).^2+4*d*b*(t0^n-x.^n)/(c*a)));
    z=FtesTI(x,Y1);
    Y2=V0(i)./(a+b*z);
    %Y1-Y2
    %[ii,jj]=min(abs(Y1-Y2))
    jj=find(diff(sign(Y1-Y2))~=0);
    X(i)=x(jj(end));%%%El cero mas alto
    Y(i)=Y1(jj(end));
    %plot(x,Y1,x,Y2)
end