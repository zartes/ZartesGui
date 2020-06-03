function [Ibs, Ibs_ok] = BuildIbiasFromRp(IVset,rp)
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
    raux(isinf(raux)) = NaN;
    [~,i3] = min(diff(vaux)./diff(iaux));
    Ibs = spline(raux(1:i3),iaux(1:i3),rp)*1e6;
%     Ibs = spline(raux(1:i3),iaux(1:i3),rp)*1e6;

    rp_ok = raux(find(raux > 1e-3, 1, 'last' ));
    Ibs_ok = Ibs(rp > rp_ok);
end
