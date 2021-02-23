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

str = get(src,'Label');

Data = get(src,'UserData');

switch str
    case 'Low Freq Band'
        pos = get(Data,'Position');
        prompt = {'Low Frequency band Onset','Low Frequency band Offset'};
        name = 'Low Frequency Band';
        numlines = 1;
        defaultanswer = {num2str(pos(1)),num2str(pos(1)+pos(3))};
 
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        lowfreq(1) = str2double(answer{1});
        lowfreq(2) = str2double(answer{2});                
        set(Data,'Position', [lowfreq(1) pos(2) diff(lowfreq) pos(4)]);
        
    case 'High Freq Band'        
        pos = get(Data,'Position');
        prompt = {'High Frequency band Onset','High Frequency band Offset'};
        name = 'High Frequency Band';
        numlines = 1;
        defaultanswer = {num2str(pos(1)),num2str(pos(1)+pos(3))};
 
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        Highfreq(1) = str2double(answer{1});
        Highfreq(2) = str2double(answer{2});                
        set(Data,'Position', [Highfreq(1) pos(2) diff(Highfreq) pos(4)]);
    otherwise
        
end
