function results=plotnKGfits(fits,rp)
%% acepta un cell de ajustes con un array de porcentajes a los que se han hecho.

for i=1:length(fits)

param=GetGfromFit(fits{i})
n(i)=param.n;
K(i)=param.K
Tc(i)=param.Tc;
G(i)=param.G;
end

results.n=n;
results.K=K;
results.Tc=Tc;
results.G=G;
results.rp=rp;
