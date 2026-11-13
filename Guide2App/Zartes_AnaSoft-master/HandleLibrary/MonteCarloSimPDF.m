function Narray=MonteCarloSimPDF(pdf,varargin)
%%%funcion para simular numeros con una pdf arbitraria
N=1e3;
range=[5820:5970];
p0=[1 1];%pdf(p,E)
pdflims=pdf(p0,range);
Narray=[];
for i=1:length(range)
    nx=sum(rand(1,N)<pdflims(i));
    Narray(end+1:end+nx)=range(i);
end