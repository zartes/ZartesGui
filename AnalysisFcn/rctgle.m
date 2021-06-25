function rctgle(src,evnt)

switch evnt.Button
    case 1
    case 2
    case 3
        cmenu = uicontextmenu('Visible','on');
        c1 = uimenu(cmenu,'Label','Change Freq Limits');
        c2(1) = uimenu(c1,'Label','Low Freq Band','Callback',...
            {@ActionFcn},'UserData',src);
        c2(2) = uimenu(c1,'Label','High Freq Band','Callback',...
            {@ActionFcn},'UserData',src);
        set(src,'uicontextmenu',cmenu);
        waitfor(cmenu,'Visible','off')
    otherwise
        
end



function ActionFcn(src,evnt)

a = findobj('Tag','Analyzer');
handles = guidata(a(1));
str = get(src,'Label');

Data = get(src,'UserData');

switch str
    case 'Low Freq Band'
        pos = get(Data,'Position');
        
        prompt = {'Low Frequency band Onset','Low Frequency band Offset'};
        name = 'Low Frequency Band';
        numlines = 1;
        defaultanswer = {num2str(handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Noise_LowFreq(1)),...
            num2str(handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Noise_LowFreq(2))};
 
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer)
            lowfreq(1) = str2double(answer{1});
            lowfreq(2) = str2double(answer{2});
            set(Data,'Position', [lowfreq(1) pos(2) diff(lowfreq) pos(4)]);
        else
            return;
        end
        
    case 'High Freq Band'        
        pos = get(Data,'Position');
        prompt = {'High Frequency band Onset','High Frequency band Offset'};
        name = 'High Frequency Band';
        numlines = 1;
        defaultanswer = {num2str(handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Noise_HighFreq(1)),...
            num2str(handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Noise_HighFreq(2))};     
 
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer)
            Highfreq(1) = str2double(answer{1});
            Highfreq(2) = str2double(answer{2});
            set(Data,'Position', [Highfreq(1) pos(2) diff(Highfreq) pos(4)]);
        else
            return;
        end
    otherwise
        
end
