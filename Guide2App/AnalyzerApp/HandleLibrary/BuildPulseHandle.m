function PulseH=BuildPulseHandle(varargin)
%%%
% Expresion:
% a*(exp(-(x-d)/b)-exp(-(x-d)/c)).*heaviside(x-d)+e
% a*(exp(-(x-d)/b)-exp(-(x-d)/c)-exp(-(x-d)/f)).*heaviside(x-d)+e
% a*(exp(-(x-b)/c)-exp(-(x-b)/d)-exp(-(x-b)/e)-exp(-(x-b)/f)).*heaviside(x-b)+g
%OJO al orden de los parametros
% [a taurise taufall_1 t0 DC taufall_2 taufall_3]
% a<0 para pulsos positivos!
if nargin==0
    PulseH=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3)))...
        .*heaviside(x-p(4))+p(5);
else
    switch varargin{1}
        case '2e'
            PulseH=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))-exp(-(x-p(4))/p(6)))...
        .*heaviside(x-p(4))+p(5);
        case '3e'
           PulseH=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))-exp(-(x-p(4))/p(6))-exp(-(x-p(4))/p(7)))...
        .*heaviside(x-p(4))+p(5); 
        otherwise
            error('wrong type');
    end
end