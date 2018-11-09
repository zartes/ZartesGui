function param = GetModelParameters(p,IVmeasure,Ib,TESDATA)
%extrae los parámetros térmicos del sistema a partir de un modelo térmico y
%conociendo el punto de operación y la 'G'

%known parameters
%R0=210e-3;%79e-3;
%P0=80e-15;%77e-15;
%I0=(P0/R0)^.5;
%G=1.66e-12;%1.7e-12;
%T0=0.155;%;0.07;
%global R0 P0 I0 T0 G C ai bi

Rn = TESDATA.circuit.Rn;
T0 = TESDATA.TES.Tc;
G0 = TESDATA.TES.G;
[iaux,ii] = unique(IVmeasure.ibias,'stable');
vaux = IVmeasure.vout(ii);
[m,i3] = min(diff(vaux)./diff(iaux)); %#ok<ASGLU>

%%%% Modificado por Juan %%%%%

CompStr = {'>';'';'<'};
if eval(['Ib' CompStr{median(sign(iaux))+2} 'iaux(1:i3)'])    
    P = polyfit(iaux(i3+1:end),vaux(i3+1:end),1);
    Vout = polyval(P,Ib);
else
    Vout = ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);
end

% pp = spline(iaux(1:i3),vaux(1:i3));%%ojo, el spline no es bueno fuera de la transición.
% Vout = ppval(pp,Ib);


%ind=find(abs(IVmeasure.ib-Ib)<1e-10);
%Vout=IVmeasure.vout(ind);
%[I0,V0]=GetIVTES(Vout,Ib,Rf);
IVaux.ibias = Ib;
IVaux.vout = Vout;
IVaux.Tbath = IVmeasure.Tbath;
IVstruct = GetIVTES(IVaux,TESDATA);%%%

I0 = IVstruct.ites;
V0 = IVstruct.vtes;

%R0=0.46*Rn;%0.0147;
%T0=145e-3;
%V0=0.507e-6;I0=43.78e-6;
P0 = V0.*I0;
%G=716e-12;
R0 = V0/I0;
%%%%%test
%G0=spline([TES.Gset.rp],[TES.Gset.G],R0/Rn)*1e-12
%T0=spline([TES.Gset.rp],[TES.Gset.Tc],R0/Rn)
%pause(1)
%R0/Rn

rp = p(1,:);
rp_CI = p(2,:);
rp(1,3) = abs(rp(3));
if(length(rp) == 3)
        %derived parameters
        %for simple model rp(1)=Zinf, rp(2)=Z0, rp(3)=taueff
        %rp=real(p);
        %El orden importa a la hora de exportar los datos.
        param.rp = R0/Rn;
        param.L0 = (rp(2)-rp(1))/(rp(2)+R0);  
%         param.L0_CI = sqrt( ((1/(R0 + rp(2)) - (rp(2) - rp(1))/(R0 + rp(2))^2)*rp_CI(2))^2 + ((-1/(R0 + rp(2)))*rp_CI(1))^2 );       
        
        param.L0_CI = sqrt((((rp(1)+R0)/((rp(2)+R0)^2))*rp_CI(2))^2 + ((-1/(R0 + rp(2)))*rp_CI(1))^2 );
        
        param.ai = param.L0*G0*T0/P0;
        param.ai_CI = sqrt(((G0*T0/P0)*param.L0_CI)^2);
        param.bi = (rp(1)/R0)-1;
        param.bi_CI = sqrt(((1/R0)*rp_CI(1))^2);        
        param.taueff = rp(3);
        param.taueff_CI = rp_CI(3);
        param.tau0 = rp(3)*(param.L0-1);
        param.tau0_CI = sqrt(((param.L0-1)*rp_CI(3))^2 + ((rp(3))*param.L0_CI)^2 );
        param.C = param.tau0*G0;        
        param.C_CI = sqrt(((G0)*param.tau0_CI)^2 );
        param.Zinf = rp(1);
        param.Zinf_CI = rp_CI(1);
        param.Z0 = rp(2);
        param.Z0_CI = rp_CI(2);
        
    elseif(length(p) == 5)
        %derived parameters for 2 block model case A
        param.rp = R0/Rn;
        param.L0 = (rp(2)-rp(1))/(rp(2)+R0);
        param.ai = param.L0*G0*T0/P0;
        param.bi = (rp(1)/R0)-1;       
        param.tau0 = rp(3)*(param.L0-1);
        param.taueff = rp(3);
        param.C = param.tau0*G0;
        param.Zinf = rp(1);
        param.Z0 = rp(2);
        param.CA = param.C*rp(4)/(1-rp(4));
        param.GA = param.CA/rp(5);
        param.tauA = rp(5);
        param.ca0 = rp(4);
    elseif(length(p) == 7)
        param = nan;
end


