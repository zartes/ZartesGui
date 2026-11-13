function Cv=CvDesign(T,varargin)
%Calculo capacidades termicas para varios materiales.
%Calcula la suma de la contribución eléctrica y phononica, 
%pero ojo, para el molibdeno no tengo datos para la contribución 
%phononica. 
%Para calcular la Celectrica de una bicapa tengo CthCalc.

%Encuentro una referencia con las Td de los elementos:
%https://www.knowledgedoor.com/2/elements_handbook/debye_temperature.html
%Los valores no coinciden exactamente, pero aparece la del Mo.
%Encuentro tb referencia con las Ef de Mo,W y Ta.
%((http://iopscience.iop.org/0953-8984/10/48/005) tabla1.)
%Da Ef=0.4978Ryd=6.77eV para el Mo. Coincide con el irwin?
%Tf(K)=1.16e4*E(eV)

%definicion materiales. Ef(eV).densidad(Kg/m^3).
%%%ORO
oro.Ef=5.53;oro.Tf=6.42e4;oro.TD=165;
oro.densidad=19.32e6;oro.masa_molar=196.967;
oro.att_length6K=1.1755e-6;
oro.conductivity=5e-9;
oro.f_obs_free=1.1355;
%%%Molibdenum
molibdeno.Ef=6.77;molibdeno.Tf=7.85e4;molibdeno.TD=423;
molibdeno.densidad=10.22e6;molibdeno.masa_molar=95.96;
molibdeno.f_obs_free=1;%*
molibdeno.att_length6K=0;%*
molibdeno.conductivity=0;%*
%%%Bismuto
bismuto.Ef=9.9;bismuto.Tf=11.5e4;bismuto.TD=119;
bismuto.densidad=9.7e6;bismuto.masa_molar=208.98;
bismuto.att_length6K=2.091e-6;
bismuto.f_obs_free=0.0224;%%%0.008 frente a 0.3566!
%%%valores tomados de: http://hyperphysics.phy-astr.gsu.edu/hbase/Tables/fermi.html
%%% Esto da un valor para gamma de 356.6 microJ/molK^2 mientras que el
%%% valor tabulado por Irwin es de 8uJ/molK^2. Esta diferencia hace que
%%% según el cálculo de Irwin la contribución del Bi sea despreciable
%%% mientras que según este cálculo sí sería apreciable. En cualquier caso
%%% la contribución electronica domina la phononica.

%%%COBRE
cobre.Ef=7;cobre.Tf=8.16e4;cobre.TD=315;
cobre.densidad=8.96e6;cobre.masa_molar=63.536;
cobre.att_length6K=9.85e-6;
cobre.f_obs_free=1.38;
%%%SILICIO
silicio.Ef=Inf;silicio.Tf=Inf;silicio.TD=645;
silicio.densidad=2.33e6;silicio.masa_molar=28.09;
silicio.att_length6K=30.345e-6;
silicio.f_obs_free=1;
%%%NITRURO SILICIO
Si3N4.Ef=Inf;Si3N4.Tf=Inf;Si3N4.TD=1060;
Si3N4.densidad=3.2e6;Si3N4.masa_molar=140.28;
Si3N4.att_length6K=30e-6;%%%esto es la membrana, no interesa como absorbente.
Si3N4.conductivity=0;
Si3N4.f_obs_free=1;
%%%TiO2.Ojo!!! CUORE es TeO2!!!
TiO2.Ef=Inf;TiO2.Tf=Inf;%%%!!!
TiO2.TD=232;TiO2.densidad=4.23e3;%%%???
TiO2.masa_molar=79.866;%79.866;
TiO2.f_obs_free=1;TiO2.att_length6K=0e-6;
TiO2.conductivity=0;
%%%TeO2.CUORE
TeO2.Ef=Inf;TeO2.Tf=Inf;%%%!!!
TeO2.TD=232;TeO2.densidad=5.67e6;%4.23e3;%%%???
TeO2.masa_molar=159.6;%79.866;
TeO2.f_obs_free=1;TeO2.att_length6K=0e-6;
TeO2.conductivity=0;
%%%Wolframio
W.Ef=11.47;W.Tf=13.37e4;W.TD=383;
W.densidad=19.316e6;W.masa_molar=183.84;
W.att_length6K=0;%*
W.conductivity=0;%*
W.f_obs_free=1;%*
% E_fermi=[5.53,9.9,7,Inf]; %energias de fermi en eV.
% %Ef=5.53; %eV
% T_fermi=[6.42e4,11.5e4,8.16e4,Inf]; %en Kelvin
% %Tf=6.42e4; %k
% T_Debye=[165,119,315,645];%en kelvin.
% %TD=165; %K
% densidad=[19.32, 9.7,8.96 , 2.33]*1e6; %en g/m3
% %d=19.3*1e6; %densidad en g/m^3
% masa_molar=[196.967,208.98,63.536,28.09]; %en g/mol
%M=196.967; %masa molar en g/mol
%cve=8.31*pi^2*(.5*(T/Tf))

if nargin==1
    material_str='oro';%'bismuto';%'oro'
    %geometria y parametros del TES.
    %sizes=[50, 100, 150,200,250]*1e-6;
    %sizes=100e-6;%bismuto.
    sizes=500e-6;%%%Oro 1Z1_62A
    %sizes=150e-6;
    %sizes=sqrt(100*140)*1e-6;
    A=sizes.^2; %area
    h=2.5e-6;   %altura.Au del 1Z10_45A:1.5e-6, 1Z10_62A:2.4e-6.
    %h=265e-9;
    %h=340e-9;
    %h=6e-6; %bismuto
else
    option=varargin{1};
    material_str=option.material;
    %sizes=option.sizes;
    A=option.A;
    h=option.h;
end

switch material_str
    case 'oro'
        material=oro;
    case 'molibdeno'
        material=molibdeno;
    case 'bismuto'
        material=bismuto;
    case 'cobre'
        material=cobre;
    case 'silicio'
        material=silicio;
    case 'Si3N4'
        material=Si3N4;
    case 'TiO2'
        material=TiO2;
    case 'TeO2'
        material=TeO2;
    case 'Wolframio'
        material=W;
end
%material=oro;%Si3N4;%oro
Tf=material.Tf;TD=material.TD;d=material.densidad;M=material.masa_molar;L=material.att_length6K;
f_obs_free=material.f_obs_free;
%rho=material.conductivity;

R=8.31;
cve=R*pi^2*(.5*(T/Tf))*f_obs_free;
cvp=R*pi^2*((12*pi^2/5)*(T/TD).^3); % J/K*mol
cv=cve+cvp;
%definimos sensitivity as T/E (incremento de temperatura esperado para un
%determinado depósito de energía). De Q=cv(g)*m*T=E -> S=1/cv(g)*M
% m=d*A*h

Nmol=A*h*d/M
Cve=cve*Nmol
Cvp=cvp*Nmol
Cv=cv*Nmol;

%disp(Cv)
return;


%S=M/(cv*d*A*h)*1.602e-19 *1e3; %K/keV
alfa=100;
Emax=10; %keV
Tc=0.1;%K
rmax=0.8;rmin=0.2;rop=0.2;%valores de resistencia en unidades de Rn.
rango=(rmax-rmin)/rop; %= 0.8Rn/0.1Rn (rango lineal / pto operacion). En tesis wouter usa 0.8Rn/0.5Rn=1.6;

hmin=1.602e-19 *1e3*(alfa*Emax/(rango*Tc))*M./(cv*d*A); eff=1-exp(-hmin/L);
format shortG
%disp([hmin;eff])
printmat([hmin;eff],'','hmin eff','50 100 150 200 250');
%[cv*d*A*h/M,alfa*Emax*1.602e-19 *1e3/(rango*Tc)]

%Resolucion y conductancia al baño.
Kb=1.38e-23;
n=3.2;gamma=n/(2*n+1);
%Cmin=cv*d*A.*hmin/M;
Cmin=alfa*Emax*1.602e-19 *1e3/(rango*Tc);
%Cmin=1e-12;
ji=(2/alfa)*(n*gamma*alfa^2+n^2).^.25;
ResTh=2.35*ji*sqrt(Kb*Cmin)*Tc/1.602e-19;
disp([Cmin;ResTh])

Rn=1*rho./(hmin+200e-9)
tau_eff_max=100e-6;
Lin=5e-9;Rop=Rn*rop;tau_el=Lin./Rop;
tau_eff_min=3.7*tau_el;
Gmin=Cmin./(tau_eff_max*(1+alfa/n));
Gmax=Cmin./(tau_eff_min*(1+alfa/n));
disp([Gmin,Gmax])