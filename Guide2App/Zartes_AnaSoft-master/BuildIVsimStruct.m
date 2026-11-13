function IVsim=BuildIVsimStruct(IV,TES)
%%%Creo una estructura similar a la que se genera con los datos
%%%experimentales.

Ic=TES.Ic;
Tc=TES.Tc;
Rn=TES.Rn;
%IVsim.ites=IV.ites/Ic;
%IVsim.ttes=IV.ttes/Tc;
IVsim.ites=IV.ites;
IVsim.ttes=IV.ttes;
%Vtes=Ib*Rsh-Ites*(Rsh+Rpar);
IVsim.rtes=FtesTI(IVsim.ttes/Tc,IVsim.ites/Ic);
IVsim.Rtes=IVsim.rtes*Rn;
IVsim.vtes=IV.ites.*IVsim.Rtes;
IVsim.ptes=IV.ites.*IVsim.vtes;
IVsim.Tbath=IV.Tbath;