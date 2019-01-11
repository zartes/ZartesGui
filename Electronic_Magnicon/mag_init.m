function s = mag_init(s)
% Function to initialize the electronic magnicon communication via serial
% port.
%
% Input:
% - COM: Serial port, 'COM5' for example.
%
% Output:
% - s: communication object referring to electronic magnicon
%
% Last update: 26/06/2018
% 
% if nargin == 0 % values by default of the serial port
%     s.COM = 'COM5';
% else
%     s.COM = COM;
% end
% Serial connection object is created
s.ObjHandle = instrfind('type','serial','Port',s.COM);

switch length(s.ObjHandle)
    case 0 % Non exits, then created
        s.ObjHandle = serial(s.COM);
        fopen(s.ObjHandle);
    case 1 % If exists and it is closed, then it is opened
        if (strcmp(s.ObjHandle.Status,'closed')) 
            try
                fopen(s.ObjHandle);
            catch
                disp('Error connecting Electronic Magnicon, please check connectivity');
            end
        end
    otherwise  % When many are created, only one is kept and case 1 is repeated.      
        for i = 2:length(s.ObjHandle) 
            delete(s.ObjHandle(i));
        end
        s.ObjHandle = s.ObjHandle(1);
        if (strcmp(s.ObjHandle.Status,'closed')) 
            fopen(s.ObjHandle);
        end
end
            
% Serial Port configuration setting
set(s.ObjHandle,'baudrate',s.baudrate,'databits',s.databits,'parity',s.parity,'timeout',s.timeout,'terminator',s.terminator);
