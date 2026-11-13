function F=Ecs1TB_SteadyState(y,Tb,Ib)
%%%ecuaciones de estado estacionario para 1TB.
Ites=abs(y(1));
Ttes=abs(y(2));
    n=3.067;K=1.769e-9;Rsh=2e-3;RL=2.182e-3;
    P=@(x,y) K*(x.^n-y.^n);
F(1)=Ites^2*GompertzRTI(Ttes,Ites)-P(Ttes,Tb);
F(2)=Ib*Rsh-Ites*(RL+GompertzRTI(Ttes,Ites));