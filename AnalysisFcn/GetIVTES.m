function IVstruct = GetIVTES(IVmeasure,TESDATA)
%Version de GetIVTES que devuelve estructura y acepta estructura de
%Circuito y Medida.
%Get ites and vtes from measured vout and ibias and values of Rf and Rsh.

Circuit = TESDATA.circuit;
% IVstruct = {[]};
for i = 1:length(IVmeasure)
    Tbath = IVmeasure(i).Tbath;

    %!
    %IVmeasure(i).voutc=IVmeasure.vout;
    %IVmeasure(i).ibias=IVmeasure.ib;
    
    invMf = Circuit.invMf;
    invMin = Circuit.invMin;
    Rpar = Circuit.Rpar;
    Rsh = Circuit.Rsh;
    Rf = Circuit.Rf;
    Rn = Circuit.Rn; %Sólo 

%     if nargin == 3 
%         TES = varargin{1};
%         Rn = TES.Rn; %Si no cargamos la estructura TES, la Rn podemos pasarla a través de la estructura Circuit. Pasar TES tiene sentido para usar la 'K' y 'n' para deducir la Ttes.
%     end

    F = invMin/(invMf*Rf);%36.51e-6;
    %F=36.52e-6;
    ites = IVmeasure(i).vout*F;
    Vs = (IVmeasure(i).ibias-ites)*Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
    vtes = Vs-ites*Rpar;
    ptes = vtes.*ites;
    IVstruct(i).ibias = IVmeasure(i).ibias;
    IVstruct(i).vout = IVmeasure(i).vout;
    IVstruct(i).Rtes = vtes./ites;
    IVstruct(i).rtes = IVstruct(i).Rtes/Rn;
    IVstruct(i).ites = ites;
    IVstruct(i).vtes = vtes;
    
    if ~isempty(TESDATA.TES.n)
        IVstruct(i).ttes = (ptes./[TESDATA.TES.K]+Tbath.^([TESDATA.TES.n])).^(1./[TESDATA.TES.n]);
        smT = smooth(IVstruct(i).ttes,3);
        smI = smooth(IVstruct(i).ites,3);
        %%%%alfa y beta from IV
        IVstruct(i).rp2 = 0.5*(IVstruct(i).rtes(1:end-1) + IVstruct(i).rtes(2:end));%%% el vector de X.
        IVstruct(i).aIV = diff(log(IVstruct(i).Rtes))./diff(log(smT));
        IVstruct(i).bIV = diff(log(IVstruct(i).Rtes))./diff(log(smI));
    end
    IVstruct(i).ptes = ptes;
    
    if isfield(IVmeasure,'good')
        IVstruct(i).good = IVmeasure(i).good;
    else
        IVstruct(i).good = 1;
    end
    % A�adido para saber de donde proceden, si se da este dato.
    if isfield(IVmeasure,'file')
        IVstruct(i).file = IVmeasure(i).file;
    end
        %%%%Para no machacarlo si ya existe.
    
    IVstruct(i).Tbath = Tbath;
%     IVstruct(i).range = IVmeasure(i).range;
end
