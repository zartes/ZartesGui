function mar=make_martinis_structure()
%%%%default martinis structure

%%%valores 
mar.Tc0=1;%%%en kelvin
mar.t=0.1;
mar.dmo=55; %%%en nm
mar.dau=115;
mar.Tc=martinis(mar.dmo,mar.dau,mar.t,mar.Tc0*1000,1);%%%ojo, aqui la Tc0 se pasa en mK.

%%%errores
mar.dTc0_p=0.01;
mar.dt_p=0.01;
mar.ddmo_p=0.01;
mar.ddau_p=0.01;

mar.sig=martinis_errors(mar);