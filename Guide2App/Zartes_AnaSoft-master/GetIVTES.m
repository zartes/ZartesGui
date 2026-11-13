function IVstruct=GetIVTES(Circuit,IVmeasure,varargin)
%Version de GetIVTES que devuelve estructura y acepta estructura de
%Circuito y Medida.
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.



for i=1:length(IVmeasure)
    Tbath=IVmeasure(i).Tbath

    %!
    %IVmeasure(i).voutc=IVmeasure.vout;
    %IVmeasure(i).ibias=IVmeasure.ib;
    if isa(Circuit.invMf,'PhysicalMeasurement')
        invMf=Circuit.invMf.Value;
        invMin=Circuit.invMin.Value;
        Rpar=Circuit.Rpar.Value;
        Rsh=Circuit.Rsh.Value;
        Rf=Circuit.Rf.Value;
        Rn=Circuit.Rn.Value; %Sól
    else
        invMf=Circuit.invMf;
        invMin=Circuit.invMin;
        Rpar=Circuit.Rpar;
        Rsh=Circuit.Rsh;
        Rf=Circuit.Rf;
        Rn=Circuit.Rn; %Sólo
    end

    if nargin==3
        TES=varargin{1};
        %Rn=TES.Rn; %Si no cargamos la estructura TES, la Rn podemos pasarla a través de la estructura Circuit. Pasar TES tiene sentido para usar la 'K' y 'n' para deducir la Ttes.
    end

    F=invMin/(invMf*Rf);%36.51e-6;
    %F=36.52e-6;
    ites=IVmeasure(i).vout*F;
    Vs=(IVmeasure(i).ibias-ites)*Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
    vtes=Vs-ites*Rpar;
    ptes=vtes.*ites;
    IVstruct(i).ibias=IVmeasure(i).ibias;
    IVstruct(i).vout=IVmeasure(i).vout;
    IVstruct(i).Rtes=vtes./ites; 
    if ites==0 IVstruct(i).Rtes=0;end
    IVstruct(i).rtes=IVstruct(i).Rtes/Rn;
    IVstruct(i).ites=ites;
    IVstruct(i).vtes=vtes;
    
    if nargin==3
        IVstruct(i).ttes=(ptes./[TES.K]+Tbath.^([TES.n])).^(1./[TES.n]);
        smT=smooth(IVstruct(i).ttes,3);
        smI=smooth(IVstruct(i).ites,3);
                %%%%alfa y beta from IV
     IVstruct(i).rp2=0.5*([IVstruct(i).rtes(1:end-1)]+[IVstruct(i).rtes(2:end)]);%%% el vector de X.
     IVstruct(i).aIV=diff(log(IVstruct(i).Rtes))./diff(log(smT));
     IVstruct(i).bIV=diff(log(IVstruct(i).Rtes))./diff(log(smI));
    end
    IVstruct(i).ptes=ptes;
    
    if isfield(IVmeasure,'good') IVstruct(i).good=IVmeasure(i).good; else IVstruct(i).good=1; end %%%%Para no machacarlo si ya existe. y si no, lo creo.
    
    IVstruct(i).Tbath=Tbath;
    
    %%%%%Spline IV
    %[max,ii]=max(abs(IVmeasure(i).vout));
    
end
