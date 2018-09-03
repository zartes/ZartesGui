function [signo,pol,dire] = IbvaluesExtraction(Ibvalues)
signo = sign(Ibvalues(1));
signo_end = sign(Ibvalues(end));
switch signo
    case 1  % from positive to less positive values
        pol = 'p';
        dire = 'down';
    case -1
        pol = 'n';
        dire = 'down';
    case 0
        if signo_end % positive
            pol = 'p';
        else
            pol = 'n';
        end
        dire = 'up';
end