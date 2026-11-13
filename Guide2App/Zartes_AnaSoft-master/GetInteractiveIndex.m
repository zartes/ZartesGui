function output_txt = GetInteractiveIndex(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
%%%Funcion para extraer el index de un plot de datos y pintar eventualmente
%%%el pulso asociado a ese index junto con el fit.

pos = get(event_obj,'Position');
data = get(event_obj,'Target');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end

index=find(data.XData==pos(1) & data.YData==pos(2))
% filename='Pulsos10000_50mK_140uA_oxford_PI_normal_9am_16J.fits';
% pulso=fitsread(filename,'binarytable',1,'TableColumns',1,'TableRows',index);
% figure(5)
% plot(time,pulso{1},'.-')
if(0)
    subplot(1,2,2)
    str_name='p20k_fitted';
    vars=evalin('base','who');
    xxx=strfind(vars,str_name);
    sum(cellfun(@any,xxx))
    if sum(cellfun(@any,xxx))
        str=evalin('base',str_name);
        file=str.names{index}
    else
        ind=index;
    end
    opt.RL=2e3;opt.SR=1e5;
    strcat('Pulsos_float20000\',file)
    pulso=readFloatPulse(strcat('Pulsos_float20000\',file),opt);
    %hold off
    plot(pulso(:,1),pulso(:,2));hold on, grid on
    fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4));
    p=[str.A(index) str.tau_fall(index) str.tau_rise(index) str.t0(index)];
    plot(pulso(:,1),str.dc(index)+fhandle(p,pulso(:,1)),'r')
end
%ind=index
%plotAllPulsos('Pulsos_float20000',ind)