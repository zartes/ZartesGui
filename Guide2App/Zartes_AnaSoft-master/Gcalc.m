function G=Gcalc(par)

ji=0.8;
S=1e9;
area=par.sides*4*par.membrane.h;
V=par.sides^2*par.hAu;
Tc=par.Tc;
G.Gmem=4*157*area*ji*Tc.^3;
G.Geph=5*S*V*Tc.^4;