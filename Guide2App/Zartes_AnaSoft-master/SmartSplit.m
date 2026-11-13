function [ncols,nrows]=SmartSplit(N)
%%%% función para partir una figura con 'N' subplots en un array con una
%%%% distribución optimizada.
switch N
    case 1
        ncols=1; 
        nrows=1;
    case 2
        ncols=1; 
        nrows=2;
    case 3
        ncols=1; 
        nrows=3;
    case 4
        ncols=2; 
        nrows=2;
    case 5
        ncols=3; 
        nrows=2;
    case 6
        ncols=3; 
        nrows=2;
    case 7
        ncols=4; 
        nrows=2;
    case 8
        ncols=4; 
        nrows=2;
    case 9
        ncols=3; 
        nrows=3;
    case 10
        ncols=5; 
        nrows=2;
    case 11
        ncols=4; 
        nrows=3;
    case 12
        ncols=4; 
        nrows=3;
    otherwise
        nrows=4;
        ncols=max(ceil(N/nrows),1);
end    