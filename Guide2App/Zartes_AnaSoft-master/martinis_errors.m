function dTc=martinis_errors(args_in)
%%%%funcion para calcular el error en la Tc a partir de errores en cada uno
%%%%de los parámetros de entrada a partir de las fórmulas analíticas.

%dTc/Tc=...(1-4) para Tc0, 't', 'dMo', 'dAu'.

Tc=args_in.Tc;
Tc0=args_in.Tc0;
t=args_in.t;
dmo=args_in.dmo;
dau=args_in.dau;
b=0.369*dau./dmo;
dTc0_p=args_in.dTc0_p;
dt_p=args_in.dt_p;
ddau_p=args_in.ddau_p;
ddmo_p=args_in.ddmo_p;
dTc1=(1+b).*(Tc).*dTc0_p;%%%dTc0_p=(dTc0./Tc0);
dTc2=-b.*(Tc).*dt_p;%%%dt_p=(dt./t);
dTc3=(log(Tc./Tc0)+b./(1+b)).*Tc.*ddau_p;%%%ddau_p=(ddau./dau);
dTc4=(-log(Tc./Tc0)+b.^2./(1+b)).*Tc.*ddmo_p;%%%ddmo_p=(ddmo./dmo);

dTc=sqrt(dTc1.^2+dTc2.^2+dTc3.^2+dTc4.^2);