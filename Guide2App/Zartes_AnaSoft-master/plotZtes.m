function varargout=plotZtes(TFm,TFs,circuit,varargin)
%plot Ztes from measured TF and superconducting TF.

Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
Rn=circuit.Rn;
%Rsh=2e-3;
%Rpar=.12e-3;
Rth=Rsh+Rpar;
%L=78e-7;
f=TFm.f;

if nargin>3
    ind=varargin{1};
    TFN=varargin{2};
    tfsn=TFs.tf./TFN.tf;
    Ztes=(TFs.tf(1:ind)./TFm.tf(1:ind)-1).*(Rth+1i*2*pi*L*f(1:ind));
    Ztes=(TFs.tf(1:ind)./TFm.tf(1:ind)-1).*Rn./(tfsn(1:ind)-1);
else
    Ztes=(TFs.tf./TFm.tf-1).*(Rth+1i*2*pi*L*f);
end
varargout{1}=Ztes;
plot(Ztes,'.-');%,'b')