function R = avs_read(obj)
% Function to read voltage from AVS 47
%
% Input:
% - obj: object refering to gpib connection of the AVS 47
%
% Output:
% - R: resistence (ohms).
%
% Example of usage:
% R = avs_read_updated(obj);
%
% Last uptdate: 10/01/2019

out = query(obj.ObjHandle,['AVE ' num2str(obj.Naverages) ';']);
pause(obj.Naverages*0.4+0.2)
out = query(obj.ObjHandle,'AVE?;');
R = str2num(out(4:end));  % Alternative line: Vdc = str2double(out);