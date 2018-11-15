function Data2Fitting(src,evnt)
    
Xdata = src.UserData.Xdata;  
Ydata = src.UserData.Ydata;
Name = src.UserData.Name;
warning off
handles = guidata(src);
for i = 1:length(Xdata)
    if isnan(Xdata{i})
        p{i} = [NaN NaN];
    else
        [p{i}, s] = polyfit(Xdata{i},Ydata{i},1);
        ButtonName = questdlg(['Relate this slope value of : ' num2str(p{i}(1)*1e06) ' Ohm to:'], ...
            'Slope Measurement', ...
            'mN', 'mS', 'Cancel','Cancel');
        switch ButtonName
            case 'mN'
                handles.Circuit.mN.Value = p{i}(1)*1e06;
                handles.Circuit.mN.Units = 'Ohm';
                handles.mN.fit = 'linear';
                handles.mN.Data = [Xdata{i} Ydata{i}];
                handles.mN.FileName = Name;
                handles.Menu_Circuit.UserData = handles.Circuit;
            case 'mS'
                handles.Circuit.mS.Value = p{i}(1)*1e06;
                handles.Circuit.mS.Units = 'Ohm';
                handles.mS.fit = 'linear';
                handles.mS.Data = [Xdata{i} Ydata{i}];
                handles.mS.FileName = Name;
                handles.Menu_Circuit.UserData = handles.Circuit;
            case 'Cancel'
                
        end % switch        
    end        
end


guidata(src,handles);
% La idea es acotar los datos que hay dentro del rectangulo para hacer un
% fitting lineal y obtener la pendiente de la recta. Si es mN es la
% pendiente de la recta en estado normal, y mS la pendiente de la recta en
% estado superconductor. Con estas medidas se actualizan los valores de la
% estructura Circuit. 


% end