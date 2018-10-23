function MakeIbFile(varargin)
format short eng
ib=[];
for i=1:nargin
    ib=[ib ;varargin{i}(:)];
end
ib
    