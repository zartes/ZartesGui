function OP=setTESOPfromIb(Ib,IV,p,varargin)
%set the TES operating point from Ibias and IV curves and fitted
%parameters p.

[iaux,ii]=unique(IV.ibias,'stable');
vaux=IV.vout(ii);
raux=IV.rtes(ii);
itaux=IV.ites(ii);
vtaux=IV.vtes(ii);
paux=IV.ptes(ii);
if (isfield(IV,'ttes')) taux=IV.ttes(ii);end
[~,i3]=min(diff(vaux)./diff(iaux));
%[m,i3]=min(diff(IV.vout)./diff(IV.ibias));%%%Calculamos el índice del salto de estado N->S.
Ibiasmin=iaux(i3);
OP.Ibiasmin=Ibiasmin;
OP.vout=ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);

if Ib<Ibiasmin OP.vout=0;end
OP.ibias=Ib;
OP.Tbath=IV.Tbath;

if nargin==4 
    Circuit=varargin{1};
    IVstruct=GetIVTES(Circuit,OP);
    OP.r0=IVstruct.rtes;
    OP.V0=IVstruct.vtes;
    OP.I0=IVstruct.ites;
    OP.R0=IVstruct.Rtes;
    OP.P0=IVstruct.ptes;
    %if (isfield(IVstruct,'ttes')) OP.T0=IVstruct.ttes;end
else
    %OP.r0=ppval(spline(IV.ibias(ii(1:i3+1)),IV.rtes(ii(1:i3+1))),Ib);
    OP.r0=ppval(spline(iaux((1:i3)),raux((1:i3))),Ib);
    %OP.V0=ppval(spline(iaux,IV.vtes(ii)),Ib);
    %OP.I0=ppval(spline(iaux,IV.ites(ii)),Ib);
    OP.V0=ppval(spline(iaux(1:i3),vtaux(1:i3)),Ib);
    OP.I0=ppval(spline(iaux(1:i3),itaux(1:i3)),Ib);
    OP.R0=OP.V0/OP.I0;
    %OP.P0=ppval(spline(iaux,IV.ptes(ii)),Ib);
    OP.P0=ppval(spline(iaux(1:i3),paux(1:i3)),Ib);
    if (isfield(IV,'ttes')) OP.T0=ppval(spline(iaux(1:i3),taux(1:i3)),Ib);end
end


if length(p)>1
    OP.ai=ppval(spline([p.rp],[p.ai]),OP.r0);
    OP.bi=ppval(spline([p.rp],[p.bi]),OP.r0);
    OP.C=ppval(spline([p.rp],[p.C]),OP.r0);
    OP.L0=ppval(spline([p.rp],[p.L0]),OP.r0);
    OP.tau0=ppval(spline([p.rp],[p.tau0]),OP.r0);
    OP.Z0=ppval(spline([p.rp],[p.Z0]),OP.r0);
    OP.Zinf=ppval(spline([p.rp],[p.Zinf]),OP.r0);
    if (isfield(p,'M'))
        OP.M=ppval(spline([p.rp],real([p.M])),OP.r0);
    end
    if (isfield(p,'Mph'))
        OP.Mph=ppval(spline([p.rp],real([p.Mph])),OP.r0);
    end
    if (isfield(p,'Mph2'))
        OP.Mph2=ppval(spline([p.rp],real([p.Mph2])),OP.r0);
    end
    %OP.G0=OP.P0*OP.ai./(OP.L0*OP.T0);
    OP.G0=OP.C./OP.tau0;
else
    OP.ai=p.ai;
    OP.bi=p.bi;
    OP.C=p.C;
    OP.L0=p.L0;
    OP.tau0=p.tau0;
    OP.Z0=p.Z0;
    OP.Zinf=p.Zinf;
    %OP.G0=OP.P0*OP.ai./(OP.L0*OP.T0);
    OP.G0=OP.C./OP.tau0;
    if (isfield(p,'M'))
        OP.M=p.M;
    end
    if (isfield(p,'Mph'))
        OP.Mph=p.Mph;
    end
    if (isfield(p,'Mph2'))
        if isempty(p.Mph2) p.Mph2=0;end
        OP.Mph2=p.Mph2;
    end
    OP.P=p;%%%%Para modelos a 2TB necesitamos parámetros que no están en el modelo simple
end