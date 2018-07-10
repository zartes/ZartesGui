function IV = acquire_Pos_Neg_Ivs_updated(Temp, Ibias)
% Wrapper function to acquire both current polarities at once.
% 
% Input: 
% - Temp: milliKelvin (String )
% - Ibias: current values in uA
% 
% Output: 
% - IV.ivp: Positive IV polarity values
% - IV.ivn: Negative IV polarity values
%
% Example: 
% IV = acquire_Pos_Neg_Ivs('4mK', )
%
% Last update: 28/06/2018

IV.ivp = acquireIVs_updated(Temp, Ibias);
IV.ivn = acquireIVs_updated(Temp, -Ibias);