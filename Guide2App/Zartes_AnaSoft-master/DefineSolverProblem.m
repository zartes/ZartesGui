function problem=DefineSolverProblem(ib,tb,y0,TESparam,Circuitparam,varargin)
if nargin==6
    options=varargin{1};
    problem.options=options;
end

    Rsh=Circuitparam.Rsh;Rpar=Circuitparam.Rpar;Rn=TESparam.Rn;
    Ic=TESparam.Ic;Tc=TESparam.Tc;
    n=TESparam.n;K=TESparam.K;
    
    %tb=Tb/Tc;ib=Ib/Ic;ub=tb^n;
    rp=Rpar/Rsh;rn=Rn/Rsh; %Normalizando a Rsh
    %rp=Rpar/Rn;rsh=Rsh/Rn; %Normalizando a Rn.
    A=(Tc^n*K)/(Ic^2*Rn); %
    %A=(Tc^n*K)/(Ic^2);%normalizado a Rn.

f = @(y) NormalizedGeneralModelSteadyState(y,ib,tb,A,rp,rn,n);%y(1)=it,y(2)=tt.

problem.objective=f;
problem.x0=y0;
problem.solver='fsolve';

