function pxi_ConfigureTrigger_updated(pxi)
% Function to set configuration of the Trigger Mode of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_ConfigureTrigger_updated(pxi)
%
% Last update: 06/07/2018

%% Función para configurar el trigger.

switch pxi.ConfStructs.Trigger.Type
    case 1 %%%modo edge  %%%%pxi.Triggering.Trigger_Type
    invoke(pxi.ObjHandle.Configurationfunctionstrigger,'configuretriggeredge',...
        pxi.ConfStructs.Trigger.Source,...
        pxi.ConfStructs.Trigger.Level,...
        pxi.ConfStructs.Trigger.Slope,...
        pxi.ConfStructs.Trigger.Coupling,...
        pxi.ConfStructs.Trigger.Holdoff,...
        0); % Delay   
    case 6 %%%modo immediate
        invoke(pxi.ObjHandle.Configurationfunctionstrigger,'configuretriggerimmediate');
    otherwise
        warndlg('Trigger Type value not expected, select 1 or 6 instead.','ZarTES');
end
    
