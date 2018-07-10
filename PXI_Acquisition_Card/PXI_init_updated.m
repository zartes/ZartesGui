function pxi = PXI_init_updated()
% Function to initialize the mode Sine Sweept in the DSA HP3562A device
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi = PXI_init_updated()
%
% Last update: 05/07/2018

%% Función para inicializar una sesión de comunicación con la tarjeta PXI

device_name = 'PXI1Slot3_3'; % Es el nombre que aparece en el Ni-MAX
pxi.ObjHandle = icdevice('pxi5922.mdd', device_name);
connect(pxi.ObjHandle);

% pxi=instrfind('type','IVIInstrument'); %%%OJO! da error!!! pq?!
% 
% switch length(pxi)
%     case 0
%         pxi=icdevice('pxi5922.mdd',device_name);
%         connect(pxi)
%     case 1
%         if (strcmp(pxi.Status,'closed')) fopen(pxi);end
%     otherwise        
%         for i=2:length(pxi) delete(pxi(i));end
%         pxi=pxi(1);
%         if (strcmp(pxi.Status,'closed')) fopen(pxi);end
% end

