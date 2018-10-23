function [IVsim,xf]=simIV(Tb,varargin)

%scan parameters
%Imax=2e-3; %en mA %2e-3;
Imax=0.5e-3;
Imin=0.e-3;%0.5e-3;
Ib=linspace(Imin,Imax,100);

%relatstep=-1e-2;
%Ib=Imin:relatstep*Imax:Imax;
%Ib=Imax:-1e-2*Imax:Imin;

%parametros del TES
if nargin==1
    %default parameters
    Rsh=2e-3;Rpar=0.4e-3;%circuito
    n=3.2;K=1e-11;%membrana
    Rn=20e-3;Tc=0.1;Ic=1e-3;%TES
    Circuitparam.Rsh=Rsh;Circuitparam.Rpar=Rpar;TESparam.Rn=Rn;
    TESparam.Ic=Ic;TESparam.Tc=Tc;TESparam.n=n;TESparam.K=K;
    Circuitparam.Rf=3e3;
    Circuitparam.invMf=66;
    Circuitparam.invMin=24.1;
else
    TESparam=varargin{1};
    Circuitparam=varargin{2};
    Rsh=Circuitparam.Rsh;Rpar=Circuitparam.Rpar;Rn=TESparam.Rn;
    Ic=TESparam.Ic;Tc=TESparam.Tc;
    n=TESparam.n;K=TESparam.K;
    
end

crs=Rsh/(Rsh+Rpar);crn=Rsh/(Rsh+Rpar+Rn);

%normalized parameters:
tb=Tb/Tc;ib=Ib/Ic;ub=tb^n;
%rp=Rpar/Rsh;rn=Rn/Rsh;%used only when calling NormalizedGMS directly.
%A=(Tc^n*K)/(Ic^2*Rn);

%options = optimset( 'TolFun', 1.0e-12, 'TolX',1.0e-12,'jacobian','off','algorithm','levenberg-marquardt','maxfunevals',500);%,'plotfcn',@optimplotfirstorderopt);
options = optimset( 'TolFun', 1.0e-15, 'TolX',1.0e-15,'jacobian','off','algorithm','trust-region-reflective');%{'levenberg-marquardt',0.001});
ites=zeros(1,length(Ib));
ttes=zeros(1,length(Ib));

%out(1)=crn*ib(1);
%out(2)=(((Ic*ites(1)).^2*Rn/K+Tb^n).^(1/n))/Tc;
 
out(1)=K*(Tc^n-Tb^n)/(Ib(end)*Rsh*Rn/(Rsh+Rpar+Rn))/Ic;
out(2)=1.1;%%%1.2

for i=length(Ib):-1:1
     y0up=[crs*ib(i) tb];%%%!!!ub<->tb.
     %it0=crn*ib(i)
     %tt0=(((Ic*it0).^2*Rn*0.9/K+Tb^n).^(1/n))/Tc
     it0=abs(out(1));
     tt0=abs(out(2));
     %pause(0.5)
     y0down=[it0 tt0];%%%1.5^n<->1.5
     y0=y0down;%poner y0up para trazar subiendo.
        %TESparam.T0=Tb;TESparam.I0=cr*Ib(i);
        %cond=StabilityCheck(TESparam);
        %estab(i)=cond.stab;
        %Ib(i)
     problem=DefineSolverProblem(ib(i),tb,y0,TESparam,Circuitparam,options);  
    %f = @(y) NormalizedGeneralModelSteadyState(y,ib(i),tb,A,rp,rn,n); % function of dummy variable y
    %[out,fval,flag]=fsolve(f,y0,options);
    [out,~,flag]=fsolve(problem);
    %xf(i)=flag;
    ites(i)=out(1);
    ttes(i)=out(2);
    %ttes(i)=log(out(2))/n;
    %RtesTI(out(2),out(1))
end
%plot(Ttes,Ites)
%plot(Ib,Ites)

Ites=real(ites*Ic);
Ttes=real(ttes*Tc);
% return
% TESparam.Rsh=Rsh;TESparam.Rpar=Rpar;TESparam.Rn=Rn;
% TESparam.Ic=Ic;TESparam.Tc=Tc;

Rf=Circuitparam.Rf;
invMf=Circuitparam.invMf;
invMin=Circuitparam.invMin;
%Rf=1e3;%ojo, este parametro puede cambiar.
Mq=invMf/invMin;%cociente de inductancias mutuas 66/22.

Vout=Ites*Rf*Mq;%

if(0)
showIVsims(Ttes,Ites,Tb,Ib,TESparam,Circuitparam);
end
IV.ites=Ites;IV.ttes=Ttes;
IV.Tbath=Tb;
IVsim=BuildIVsimStruct(IV,TESparam);
IVsim.ibias=Ib;
IVsim.vout=Vout;


%Ttes(find(abs(Ttes>5)))=0;
%Ites(find(abs(Ites>.5)))=0;
%figure,plot3(Ttes,Ites,FtesTI(Ttes/0.1,Ites/1e-3),'.k')

%Ttes(find(Ttes>500))=0;
%plot3(Ttes,Ites,RtesTI(Ttes,Ites),'k')