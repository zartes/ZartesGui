function hp_Source_OFF(dsa)
% Function to deactivate the output of the source provided by HP3562A device 
% output
%
% Input:
% - dsa: Object class HP3562A
%
% Example:
% hp_Source_OFF(dsa)
%
% Last update: 06/07/2018

fprintf(dsa.ObjHandle,'SRON0');
fprintf(dsa.ObjHandle,'SROF');