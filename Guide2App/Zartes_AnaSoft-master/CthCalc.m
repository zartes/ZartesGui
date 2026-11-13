function CN=CthCalc(TES)
%%%función para calcular la C teorica de un TES de Mo Au en estado normal
%%%Se calcula sólo la contribución electronica a partir de la expresión 111
%%%de Irwin y los valores de la tabla. Válido también para absorbentes de
%%%Oro. Si no, hay que usar CvDesign.
%%%Pasamos estructura TES con campos:
%%%TES.(Tc,hMo,hAu,hBi,length,width)
gammas=[2 0.729 0.008]*1e-3; %valores de gama para Mo y Au y Bi. Multiplicado por 1e-3 para J/molK^2
rhoAs=[0.107 0.0983 0.0468]*1e6;%valores de Rho/A para Mo y Au. Multiplcado por 1e6 para mol/m^3

%hMo=55e-9; hAu=340e-9;
hMo=45e-9; hAu=265e-9;
hBi=0;%6e-6
sides=0;
TES_length=0;%%%Ojo! si se define como 'length' machaca la función!
TES_width=0;
if isfield(TES,'hMo') hMo=TES.hMo;end
if isfield(TES,'hAu') hAu=TES.hAu;end
if isfield(TES,'hBi') hBi=TES.hBi;end
if isfield(TES,'length') TES_length=TES.length;end
if isfield(TES,'width') TES_width=TES.width;end
if isfield(TES,'sides') sides=TES.sides;end
%hAu

if sides, area=sides.^2;end 
if TES_length, area=TES_length.*TES_width;end
%sides^2*hBi*rhoAs(3)
%hAu,hMo,hBi,area
if length(hAu)==1 hAu=hAu*ones(1,length(TES.Tc));end
for i=1:length(hAu)    
    %(gammas.*rhoAs).*(([hMo ;hAu(i);hBi]*sides.^2)').*TES.Tc %%%show each
    %contribution.
    CN(i)=(gammas.*rhoAs)*([hMo ;hAu(i);hBi]*area).*TES.Tc(i);
    %[hAu(i)*1e9 TES.Tc(i) CN(i)*1e15]
end