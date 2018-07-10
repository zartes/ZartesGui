function hp_Source_OFF_updated(dsa)
% Function to deactivate the output of the source provided by HP3562A device 
% output
%
% Input:
% - dsa: Object class HP3562A
%
% Example:
% hp_Source_OFF_updated(dsa)
%
% Last update: 06/07/2018

fprintf(dsa.ObjHandle,'SRON0');