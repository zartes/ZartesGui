function param=getTP(p)
Rn=fitTc(p,1.2); %consideramos que a 2K se ha alcanzado ya Rn.%ojo, obtengo NaN para algun 'p' a T=2.
T=0:1e-6:2; %array de temperaturas.
[R,param]=fitTc(p,T);
%Rn=1.064;
%R=data{2}(ind,8);
%T=data{2}(ind,3);
ind10=find(abs(R-Rn*0.1)==min(abs(R-Rn*0.1)));
T10=T(ind10);
ind90=find(abs(R-Rn*0.9)==min(abs(R-Rn*0.9)));
T90=T(ind90);
indc=find(abs(R-Rn*0.5)==min(abs(R-Rn*0.5)));
param.Tc=T(indc);
param.DT=T90-T10;
param.T90=T90;
param.T10=T10;

%OJO, estos son model dependent.
%para 'ere'
%param.alfa05=p(1)*T(indc)/(p(3)*fitTc(p,T(indc)));
%param.alfai=p(2)/p(3);
%faltaria implementar el calculo de alfa a una T dada.