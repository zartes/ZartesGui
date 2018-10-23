function OP=GetOP(Ib,Circuit,IVmeasure,TES)
% funcion para definir el punto de operacion completo de un TES a partir de la Tbath, Ib y la
% curva IV correspondiente.


ibias=Ib;
ind=abs(IVmeasure.ibias-ibias)<1e-10;
vout=IVmeasure.voutc(ind);
IVmeasure.ibias=Ib;
IVmeasure.voutc=vout;
IVstruct=GetIVTES(Circuit,IVmeasure);
OP.I0=IVstruct.ites;
OP.V0=IVstruct.vtes;
OP.P0=IVstruct.ptes;
OP.rp=IVstruct.rtes;
OP.R0=OP.V0./OP.I0;
OP.Tbath=IVmeasure.Tbath;
ttes=(OP.P0/TES.K+OP.Tbath^TES.n).^(1/TES.n);
OP.T0=ttes;

OP.Ib=Ib;