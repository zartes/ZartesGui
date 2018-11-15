function Ites = V2I(vout,circuit)
%convert Vout values to Ites

if ~isobject(circuit.invMin)
    invMin = circuit.invMin;%24.1;
    invMf = circuit.invMf;%66;
    Rf = circuit.Rf;
else
    invMin = circuit.invMin.Value;%24.1;
    invMf = circuit.invMf.Value;%66;
    Rf = circuit.Rf.Value;
end

Ites = vout*invMin/(invMf*Rf);