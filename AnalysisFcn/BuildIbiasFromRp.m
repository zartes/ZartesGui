function Ibs = BuildIbiasFromRp(IVset,rp)
% Function to get Ibias (uA) for a specific Rn value
%
% Input:
% - IVset: struct (at least IVset.ibias, IVset.vout and IVset.rtes
% - rp: percentage of Rn (%)
%
% Output:
% - Ibs: Ibias (uA)
%
% Example of usage:
% Ibs = BuildIbiasFromRp(IVset,rp)
%
% Last update: 14/11/2018

for i = 1:length(IVset)
    
    [iaux,ii] = unique(IVset.ibias,'stable');
    vaux = IVset.vout(ii);
    raux = IVset.rtes(ii);
    [~,i3] = min(diff(vaux)./diff(iaux));
    Ibs = spline(raux(1:i3),iaux(1:i3),rp)*1e6;
end
