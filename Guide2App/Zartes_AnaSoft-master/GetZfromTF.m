function ztes= GetZfromTF( tf, TFS, circuit, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if isstruct(tf)
    tfaux=tf.tf;
    f=tf.f;
else
    tfaux=tf(:,2)+1i*tf(:,3);
    f=tf(:,1);
end

tfauxHandle=@(x) interp1(f,tfaux,x);
if isstruct(TFS)
    tfsaux=TFS.tf;
    fS=TFS.f;
else
    tfsaux=TFS(:,2)+1i*TFS(:,3);
    fS=TFS(:,1);
end
tfsauxHandle=@(x) interp1(fS,tfsaux,x);

RthHandle=@(x) circuit.Rsh+circuit.Rpar+2*pi*circuit.L*x*1i;
ztesHandle=@(x) (tfsauxHandle(x)./tfauxHandle(x)-1).*RthHandle(x);
%ztes.tf=(tfsaux./tfaux-1).*Rth;
ztes.tf=ztesHandle(f);
ztes.f=f;

if nargin==4
    TFN=varargin{1};
    if isstruct(TFN)
        tfnaux=TFN.tf;
        fN=TFN.f;
    else
        tfnaux=TFN(:,2)+1i*TFN(:,3);
        fN=TFN(:,1);
    end
    tfnauxHandle=@(x) interp1(fN,tfnaux,x);
    %ztes=(TFS.tf./tf-1).*Rn./(tfsn-1);
    RthHandle=@(x)circuit.Rn./(tfsauxHandle(x)./tfnauxHandle(x)-1);
    ztesHandle=@(x) (tfsauxHandle(x)./tfauxHandle(x)-1).*RthHandle(x);
    ztes.tf=ztesHandle(f);
    ztes.f=f;
end

