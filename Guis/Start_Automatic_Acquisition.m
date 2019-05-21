function Start_Automatic_Acquisition(handles, SetupTES, Conf)


handles.Enfriada_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
if ~ischar(handles.Enfriada_dir)
    return;
end
SlashInd = strfind(handles.Enfriada_dir,filesep);
YearStr = handles.Enfriada_dir(SlashInd(end-1)+1:SlashInd(end)-1);
MonthStr = handles.Enfriada_dir(SlashInd(end)+1:end);
ExcelEnfriada = ['Summary_' YearStr '_' MonthStr '.xls'];

% Guardamos la configuracion en un .mat o en xml

% if SetupTES.CurSource_OnOff.Value
%     Conf.BField.P = str2double(SetupTES.CurSource_I.String); % Amperios
%     Conf.BField.N = str2double(SetupTES.CurSource_I.String); % Amperios
% else
    Conf.BField.P = str2double(handles.AQ_Field.String); % Amperios
    Conf.BField.N = str2double(handles.AQ_Field_Negative.String); % Amperios
% end

% Comprobar el número de RUN
dRUN = dir(handles.Enfriada_dir);
j = 0;
for i = 1:length(dRUN)
    if dRUN(i).isdir
        if ~isempty(strfind(upper(dRUN(i).name),'RUN'))
            j = j + 1;
        end
    end
end
j = j + 1;
b = num2str(j);
a = '000';
a(end-length(b)+1:end) = b;

merg = 0;
if j ~= 1
    ButtonName = questdlg('How to proceed?', ...
        'RUN Management', ...
        'New', 'Merge', 'New');
    switch ButtonName
        case 'Merge'
            handles.AQ_dir = uigetdir([handles.Enfriada_dir filesep], 'Pick a RUN Directory');
            merg = 1;
            a = handles.AQ_dir(end-2:end);
        case 'New'
            handles.AQ_dir = [handles.Enfriada_dir filesep 'RUN' a];
            [Succ, Message] = mkdir(handles.AQ_dir);
            if ~Succ
                warndlg(Message,SetupTES.VersionStr);
                msgbox('Acquisition Aborted',SetupTES.VersionStr);
                return;
            end
    end
else
    handles.AQ_dir = [handles.Enfriada_dir filesep 'RUN' a];
    [Succ, Message] = mkdir(handles.AQ_dir);
    if ~Succ
        warndlg(Message,SetupTES.VersionStr);
        msgbox('Acquisition Aborted',SetupTES.VersionStr);
        return;
    end
end

prompt = {'Insert a comment'};
name = ['Acquisition RUN' a];
numlines = [1 50];
defaultanswer = {'No comment'};

answer = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    answer{1} = '';
elseif isempty(answer{1})
    answer{1} = '';
end

if exist([handles.Enfriada_dir filesep ExcelEnfriada],'file')
    num = xlsread([handles.Enfriada_dir filesep ExcelEnfriada],2);    
    d = {str2double(a), Conf.BField.P, Conf.BField.N, answer{1}};
    try
        xlswrite([handles.Enfriada_dir filesep ExcelEnfriada], d, 2,['A' num2str(size(num,1)+2)])
    catch
        waitfor(warndlg(['Close the file name: ' ExcelEnfriada ' before push OK'],SetupTES.VersionStr));
        xlswrite([handles.Enfriada_dir filesep ExcelEnfriada], d, 2,['A' num2str(size(num,1)+2)])
    end
else
    d = {'ID_Enfriada','ID_SQUID','ID_TES','Date','Rsh','L','invMf','invMin';...
        [],[],[],[],SetupTES.Circuit.Rsh.Value,SetupTES.Circuit.L.Value,SetupTES.Circuit.invMf.Value,SetupTES.Circuit.invMin.Value};
    xlswrite([handles.Enfriada_dir filesep ExcelEnfriada], d, 1, 'A1')
    d = {'ID_RUN','FieldB pos(A)','FieldB neg(A)','Comment'; str2double(a), Conf.BField.P, Conf.BField.N, answer{1}};
    xlswrite([handles.Enfriada_dir filesep ExcelEnfriada], d, 2, 'A1')
end

if ~merg    
    IbvaluesConf('Save_Conf_Callback',handles.Save_Conf,handles.AQ_dir,guidata(handles.Save_Conf));
    save([handles.AQ_dir filesep 'Conf_Acq.mat'],'Conf');
else  % Añadir la parte del mergin    
    save([handles.AQ_dir filesep 'Conf_Acq_Merge.mat'],'Conf');
end

circuit1 = TES_Circuit;
circuit1 = circuit1.Update(SetupTES.Circuit);
CircuitProps = {'Rsh';'Rf';'invMf';'invMin';'L';'Nsquid';'Rpar';'Rn';'mS';'mN'};
for i = 1:length(CircuitProps)
    eval(['circuit.' CircuitProps{i} ' = circuit1.' CircuitProps{i} ';'])
end
save([handles.AQ_dir filesep 'circuit.mat'],'circuit');

fid = fopen([handles.AQ_dir filesep 'Readme.txt'],'a+');
fprintf(fid,[answer{1} '\n']);
fclose(fid);
   


% Generamos las carpetas donde iran las medidas

PathStr = {'Barrido_Campo';'Barrido_Campo';'IVs';'Negative_Bias'};
for i = 1:length(PathStr)
    if i == 1 && ~Conf.FieldScan.On % Solo se genera el directorio si se necesita
        continue;
    end
    if i == 2 && ~Conf.BFieldIC.On % Solo se genera el directorio si se necesita
        continue;
    end
    if i == 3 && ~Conf.IVcurves.On % Solo se genera el directorio si se necesita
        continue;
    end
    if i == 4 && (~Conf.TF.Zw.DSA.On || ~Conf.TF.Zw.PXI.On ||... % Solo se genera el directorio si se necesita
            ~Conf.TF.Noise.DSA.On || ~Conf.TF.Noise.PXI.On || ~Conf.Pulse.PXI.On || ~Conf.Spectrum.PXI.On)
        continue;
    end
    PathName = PathStr{i};
    PathName(PathStr{i} == '_') = ' ';
        
    eval(['handles.' PathStr{i} '_Dir = [handles.AQ_dir filesep ''' PathName ''' filesep];']);
    if exist(eval(['handles.' PathStr{i} '_Dir']),'dir') == 0
        [Succ, Message] = mkdir(eval(['handles.' PathStr{i} '_Dir']));
        if ~Succ
            warndlg(Message,SetupTES.VersionStr);
            msgbox('Acquisition Aborted',SetupTES.VersionStr);
            return;
        end
    end
end

% Por ahora el campo óptimo es simétrico siempre y a una corriente fija
% para todas las temperaturas.

SetupTES.CurSource_I_Units.Value = 1;
SetupTES.CurSource_I.String = num2str(Conf.BField.P*1e-6);  % Se pasan las corrientes en amperios
SetupTES.CurSource_Set_I.Value = 1;
SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
SetupTES.CurSource_OnOff.Value = 1;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));


for NSummary = 1:size(Conf.Summary,1)          
    
    % Verificar que todas las cosas se han medido en cada temperatura para
    % pasar a la siguiente
    for i = 2:size(Conf.Summary,2)
        if strcmp(Conf.Summary{NSummary,i},'Running')
            Conf.Summary{NSummary,i} = 'Yes';
            handles.Summary_Table.Data{NSummary,i} = 'Yes';
        end
    end
    
    if isempty(cell2mat(strfind(Conf.Summary(NSummary,2:end),'Yes')))
        continue;
    end
    
    Temp = Conf.Summary{NSummary,1};    
    AjustarTemperatura(Temp,Conf,SetupTES,handles)
    
    if strcmp(Conf.Summary{NSummary,2},'Yes')    % Si se mide o on 
        handles.Summary_Table.Data{NSummary,2} = 'Running';        
        [IVsetP, IVsetN] = Medir_IV(Temp,Conf,SetupTES,handles);  
        handles.Summary_Table.Data{NSummary,2} = 'Done'; 
        Conf.Summary{NSummary,2} = 'Done';
    end
    
    if strcmp(Conf.Summary{NSummary,3},'Yes')    % Si se mide o on
        handles.Summary_Table.Data{NSummary,3} = 'Running'; 
        Bfield = FieldScan(Temp,Conf,SetupTES,handles);  % Se obtiene Bfield.p y Bfield.n
        handles.Summary_Table.Data{NSummary,3} = 'Done'; 
        Conf.Summary{NSummary,3} = 'Done';
    elseif ~Conf.BField.FromScan
        Bfield.p = Conf.BField.P;
        Bfield.n = Conf.BField.N;
    end
    if Conf.BField.Symmetric
        Bfield.n = Bfield.p;
    end
    
    if strcmp(Conf.Summary{NSummary,4},'Yes')    % Si se mide o on
        handles.Summary_Table.Data{NSummary,4} = 'Running'; 
%         I_Criticas(Temp,Conf.BFieldIC.BVvalues,Conf,SetupTES,handles);
        I_Criticas_Carlos(Temp,Conf.BFieldIC.BVvalues,Conf,SetupTES,handles);
        handles.Summary_Table.Data{NSummary,4} = 'Done';
        Conf.Summary{NSummary,4} = 'Done';
    end    
    
    if strcmp(Conf.Summary{NSummary,5},'Yes') && strcmp(Conf.Summary{NSummary,6},'Yes')    % Si se mide o on
        Opt = 3; % Zw y Ruido (3)
        handles.Summary_Table.Data{NSummary,5} = 'Running';
        handles.Summary_Table.Data{NSummary,6} = 'Running'; 
    elseif strcmp(Conf.Summary{NSummary,5},'Yes') && strcmp(Conf.Summary{NSummary,6},'No')
        Opt = 1; % Sólo Zw (1)
        handles.Summary_Table.Data{NSummary,5} = 'Running'; 
    elseif strcmp(Conf.Summary{NSummary,5},'No') && strcmp(Conf.Summary{NSummary,6},'Yes')
        Opt = 2; % Sólo Ruido (2)
        handles.Summary_Table.Data{NSummary,6} = 'Running'; 
    end
    if strcmp(Conf.Summary{NSummary,5},'Yes') || strcmp(Conf.Summary{NSummary,6},'Yes')
                        
        handles.Positive_Path = [handles.AQ_dir filesep num2str(Temp*1e3,'%1.1f') 'mK' filesep];
        if exist(handles.Positive_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Positive_Path);
            if ~Succ
                warndlg(Message,SetupTES.VersionStr);
                msgbox('Acquisition Aborted',SetupTES.VersionStr);
            end
        end
        handles.Negative_Path = [handles.Negative_Bias_Dir num2str(Temp*1e3,'%1.1f') 'mK' filesep];
        if exist(handles.Negative_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Negative_Path);
            if ~Succ
                warndlg(Message,SetupTES.VersionStr);
                msgbox('Acquisition Aborted',SetupTES.VersionStr);
            end
        end
        
        % Es esencial que hayamos medido al menos una curva IV positiva y
        % otra negativa
        if ~isempty(Conf.TF.Zw.rpp)
            IZvalues.P = BuildIbiasFromRp(IVsetP,Conf.TF.Zw.rpp);
            IZvalues.P(IZvalues.P > 500) = 500;
            IZvalues.P(IZvalues.P < 0) = [];
            Medir_Zw_Noise(Temp,Opt,IZvalues.P,handles.Positive_Path,Conf,SetupTES,handles);
        end
        
        if ~isempty(Conf.TF.Zw.rpn)
            IZvalues.N = BuildIbiasFromRp(IVsetN,Conf.TF.Zw.rpn);
            IZvalues.N(IZvalues.N < -500) = -500;
            IZvalues.N(IZvalues.N > 0) = [];
            Medir_Zw_Noise(Temp,Opt,IZvalues.N,handles.Negative_Path,Conf,SetupTES,handles);
        end
        
        if strcmp(Conf.Summary{NSummary,5},'Yes') && strcmp(Conf.Summary{NSummary,6},'Yes')    % Si se mide o on
            handles.Summary_Table.Data{NSummary,5} = 'Done';
            handles.Summary_Table.Data{NSummary,6} = 'Done';
            Conf.Summary{NSummary,5} = 'Done';
            Conf.Summary{NSummary,6} = 'Done';
        elseif strcmp(Conf.Summary{NSummary,5},'Yes') && strcmp(Conf.Summary{NSummary,6},'No')
            Conf.Summary{NSummary,5} = 'Done';
            handles.Summary_Table.Data{NSummary,5} = 'Done';
        elseif strcmp(Conf.Summary{NSummary,5},'No') && strcmp(Conf.Summary{NSummary,6},'Yes')
            Conf.Summary{NSummary,6} = 'Done';
            handles.Summary_Table.Data{NSummary,6} = 'Done';
        end
    end
    
    
    if strcmp(Conf.Summary{NSummary,7},'Yes')    % Si se mide o on
        handles.Summary_Table.Data{NSummary,7} = 'Running';
        handles.Positive_Pulse_Path = [handles.AQ_dir filesep num2str(Temp*1e3,'%1.1f') 'mK' filesep 'Pulsos' filesep];
        if exist(handles.Positive_Pulse_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Positive_Pulse_Path);
            if ~Succ
                warndlg(Message,SetupTES.VersionStr);
                msgbox('Acquisition Aborted',SetupTES.VersionStr);
            end
        end
        handles.Negative_Pulse_Path = [handles.Negative_Bias_Dir num2str(Temp*1e3,'%1.1f') 'mK' filesep 'Pulsos' filesep];
        if exist(handles.Negative_Pulse_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Negative_Pulse_Path);
            if ~Succ
                warndlg(Message,SetupTES.VersionStr);
                msgbox('Acquisition Aborted',SetupTES.VersionStr);
            end
        end
        Medir_Pulsos(Temp,Conf,IZvalues.P,handles.Positive_Path,SetupTES,handles);
        Medir_Pulsos(Temp,Conf,IZvalues.N,handles.Negative_Pulse_Path,SetupTES,handles);
        Conf.Summary{NSummary,7} = 'Done';
        handles.Summary_Table.Data{NSummary,7} = 'Done';
        
        %         %%%% Falta la parte de medir N Pulsos a un Rn dado
        %         IZvalues.P = BuildIbiasFromRp(IVsetP,Conf.Pulse.PXI.Rn);
        %         Medir_Pulsos(Temp,Conf,IZvalues.P,handles.Positive_Path,SetupTES,handles);
        %%%%
    end
    
end

% Ponemos la temperatura a la que dejamos la mixing

FinalT = str2double(handles.FinalMCT.String);

SetupTES.vi_IGHFrontPanel.FPState = 4;
pause(0.1)
SetupTES.vi_IGHFrontPanel.FPState = 1;
pause(0.1)
SetupTES.vi_IGHFrontPanel.SetControlValue('Settings',1);
pause(1.5)
SetupTES.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
pause(0.1)
while strcmp(SetupTES.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
SetupTES.vi_PromptForT.SetControlValue('Set T',FinalT)%
pause(0.4)
SetupTES.vi_PromptForT.SetControlValue('Set T',FinalT)%
pause(0.1)
SetupTES.vi_PromptForT.SetControlValue('OK',1)
pause(0.1)
while strcmp(SetupTES.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
stop(SetupTES.timer_T);
start(SetupTES.timer_T);
msgbox('Acquisition complete!',SetupTES.VersionStr)


function AjustarTemperatura(Temp,Conf,SetupTES,handles)


SetupTES.vi_IGHFrontPanel.FPState = 4;
pause(0.1)
SetupTES.vi_IGHFrontPanel.FPState = 1;
pause(0.1)
SetupTES.vi_IGHFrontPanel.SetControlValue('Settings',1);
pause(1.5)
SetupTES.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
pause(0.1)
while strcmp(SetupTES.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
SetupTES.vi_PromptForT.SetControlValue('Set T',Temp)%
pause(0.4)
SetupTES.vi_PromptForT.SetControlValue('Set T',Temp)%
pause(0.1)
SetupTES.vi_PromptForT.SetControlValue('OK',1)
pause(0.1)
while strcmp(SetupTES.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
stop(SetupTES.timer_T);
start(SetupTES.timer_T);

set(SetupTES.SetPt,'String',num2str(Temp));

RGB = [linspace(120,255,100)' sort(linspace(50,170,100),'descend')' 50*ones(100,1)]./255;

Error = nan(10,1);
c = true;
j = 1;
h = waitbar(0,'Setting Mixing Chamber Temperature','WindowStyle','Modal','Name',SetupTES.VersionStr);
while c
    T_MC = SetupTES.vi_IGHFrontPanel.GetControlValue('M/C');
    Set_Pt = str2double(SetupTES.SetPt.String);
    
    %% Gestion del error de temperatura
    Error(j) = abs(T_MC-Set_Pt)/T_MC*100;
    SetupTES.Error_Measured.String = Error(j);
    try
        SetupTES.Temp_Color.BackgroundColor = RGB(min(ceil(Error(j)),100),:);
    catch
    end
    if (nanmedian(Error)&& j > 10) < 0.05
        c = false;
    else
        if nanmedian(Error) < 0.4  % Cuando la temperatura alcanza un valor con un error relativo menor al 0.4%
            h = waitbar(0,'Setting Mixing Chamber Temperature','WindowStyle','Modal','Name',SetupTES.VersionStr);
            pause(1);
            tfin = 70;
            tic;
            waitbar(0/tfin,h,'5 mins remaining for safety');
            t  = toc;
            while tfin-t > 0       
                if ishandle(h)
                    mins = floor((tfin-t)/60);
                    secs = ((tfin-t)/60-floor((tfin-t)/60))*60;
                    if mins ~= 0
                        waitbar(t/tfin,h,[num2str(mins,'%1.0f') ' min ' num2str(secs,'%1.0f') ' s remaining for safety']);
                    else
                        waitbar(t/tfin,h,[num2str(secs,'%1.0f') ' s remaining for safety']);
                    end
                end            
                %                 pause(60*5);
                pause(0.5);
                t  = toc;
            end
            c = false;
        end
    end
    j = max(mod(j+1,10),1);
    if ishandle(h)
        waitbar(j/10,h,['SetPt: ' num2str(Set_Pt) ' - M/C: ' num2str(T_MC)]);
    end
    pause(0.2);
end
close(h);

function [IVsetP, IVsetN] = Medir_IV(Temp,Conf,SetupTES,handles)

figure(SetupTES.SetupTES);
% Seleccion de Ibvalues
if Conf.IVcurves.Manual.On
    Ibvalues = Conf.IVcurves.Manual.Values;  % Ibvalues.p y Ibvalues.n
elseif Conf.IVcurves.SmartRange.On
    Ibvalues.p = 500;
    Ibvalues.n = -500;
    slope_curr = 0;
    Res_Orig = 10;
    Res = Res_Orig;
end


for IB = 1:2 % Positive 1, Negative 2
    if IB == 1
        %             Field = Bfield.p;
        IBvals = Ibvalues.p;
    else
        %             Field = Bfield.n;
        IBvals = Ibvalues.n;
    end
    
    % Ponemos el Squid en Estado Normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    %     SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(IBvals),guidata(SetupTES.SQ_TES2NormalState));
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(IBvals),guidata(SetupTES.SQ_TES2NormalState));
    pause(0.2);
    SetupTES.SQ_Ibias.String = num2str(IBvals);
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    % Reset Closed Loop
    pause(0.2);
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Adquirimos una Curva I-V
    i = 1;
    while abs(IBvals(i)) >= 0
        if IB == 1
            if IBvals(i) < 0
                break;
            end
        else
            if IBvals(i) > 0
                break;
            end
        end
        SetupTES.SQ_Ibias.String = num2str(IBvals(i));
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        if i == 1
            pause(1.5)
        else
            pause(0.6);
        end
        averages = 1;
        for i_av = 1:averages
            SetupTES.Multi_Read.Value = 1;
            SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
            aux1{i_av} = str2double(SetupTES.Multi_Value.String);
            if i_av == averages
                IVmeasure.vout(i) = mean(cell2mat(aux1));
            end
        end
        % Read I real value
        SetupTES.SQ_Read_I.Value = 1;
        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
        IVmeasure.ibias(i) = str2double(SetupTES.SQ_realIbias.String);
        
        % Actualizamos el gráfico
        Ch = findobj(SetupTES.Result_Axes,'Type','Line');
        delete(Ch);
        plot(SetupTES.Result_Axes,IVmeasure.ibias(1:i),IVmeasure.vout(1:i),'Marker','o','Color',[0 0.447 0.741]);
        hold(SetupTES.Result_Axes,'on');
        xlabel(SetupTES.Result_Axes,'Ibias (uA)')
        ylabel(SetupTES.Result_Axes,'Vout (V)');
        set(SetupTES.Result_Axes,'fontsize',12);
        refreshdata(SetupTES.Result_Axes);
        axis(SetupTES.Result_Axes,'tight');
        
        
        if Conf.IVcurves.SmartRange.On
            % Funcion para determinar el siguiente valor de Ibias en
            % función de la derivada de la señal
            if i < 12 && i > 1 % Por lo menos tendremos 5 valores para poder promediar
                slope(i-1) = (IVmeasure.ibias(i)-IVmeasure.ibias(i-1))/((IVmeasure.vout(i)-IVmeasure.vout(i-1)));
                Res = Res_Orig;
            elseif i >= 12
                slope_curr = (IVmeasure.ibias(i)-IVmeasure.ibias(i-1))/((IVmeasure.vout(i)-IVmeasure.vout(i-1)));
                
                if abs(slope_curr - nanmean(slope)) > 20*abs(nanstd(slope))
                    if slope_curr < 0
                        Res = 2;
                    else
                        Res = max(Res_Orig*0.5,1);
                    end
                else
                    Res = Res_Orig;
                end
            end
            % Aseguramos que se tome el valor de Ibias == 0
            if IB == 1
                if IBvals(i) == 0
                    IBvals(i+1) = -1;
                elseif IBvals(i)-Res < 0
                    IBvals(i+1) = 0;
                else
                    IBvals(i+1) = IBvals(i)-Res;
                end
            else
                if IBvals(i) == 0
                    IBvals(i+1) = +1;
                elseif IBvals(i) + Res > 0
                    IBvals(i+1) = 0;
                else
                    IBvals(i+1) = IBvals(i)+Res;
                end
            end
        end
        i = i+1;
    end
    
    IVmeasure.Tbath = SetupTES.SetPt.String;
    clear data;
    data(:,2) = IVmeasure.ibias;
    data(:,4) = IVmeasure.vout-IVmeasure.vout(end);  % Centramos la IV en 0,0.
    IVmeasure.vout = data(:,4)';
    
    if IBvals(1) > 0
        pol = 'p';
        dire = 'down';
    elseif IBvals(1) < 0
        pol = 'n';
        dire = 'down';
    else
        dire = 'up';
        if IBvals(end) > 0
            pol = 'p';
        else
            pol = 'n';
        end
    end
    
    file = strcat(num2str(Temp*1e3,'%1.1f'),'mK','_Rf',num2str(SetupTES.Circuit.Rf.Value*1e-3),'K_',dire,'_',pol,'_matlab.txt');
    save([handles.IVs_Dir file],'data','-ascii');
    
    % Importante que el TES_Circuit se haya actualizado con los valores de
    % Rf, mN, mS, Rpar, Rn
    
    TESDATA.circuit = TES_Circuit;
    TESDATA.circuit = TESDATA.circuit.Update(SetupTES.Circuit);
    
    IVCurveSet = TES_IVCurveSet;
    IVmeasure.ibias = IVmeasure.ibias*1e-6;
    %     IVmeasure.vout = IVmeasure.vout-IVmeasure.vout(end);
    
    IVCurveSet = IVCurveSet.Update(IVmeasure);
%     TESDATA.circuit.mN = nanmedian(diff(IVmeasure.vout(1:3))./diff(IVmeasure.ibias(1:3)));
%     TESDATA.circuit.mS = nanmedian(diff(IVmeasure.vout(end-3:end))./diff(IVmeasure.ibias(end-3:end)));
%     TESDATA.circuit = TESDATA.circuit.RnRparCalc;
    TESDATA.TES.n = [];
    if IB == 1
        IVsetP = IVCurveSet.GetIVTES(TESDATA);
        IVsetP.IVsetPath = handles.IVs_Dir;
        IVsetP.range = [Ibvalues.p 0];
    else
        IVsetN = IVCurveSet.GetIVTES(TESDATA);
        IVsetN.IVsetPath = handles.IVs_Dir;
        IVsetP.range = [Ibvalues.n 0];
    end
    clear IVmeasure;
end

function OptField = FieldScan(Temp,Conf,SetupTES,handles)

figure(SetupTES.SetupTES)
OptField = 0;
% Definir Campo_Dir (handles.Barrido_Campo)

if ~isfield(SetupTES,'IVset')
    figure(SetupTES.SetupTES)
    % Ponemos el Squid en Estado Normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(1),guidata(SetupTES.SQ_TES2NormalState));
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Adquirimos una Curva I-V para determinar la Ibias acorde con el Rn
    Ibvalues = [500:-30:110 108:-2:0];
    for i = 1:length(Ibvalues)
        SetupTES.SQ_Ibias.String = num2str(Ibvalues(i));
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        if i == 1
            pause(1.5);
        end
        averages = 1;
        for i_av = 1:averages
            SetupTES.Multi_Read.Value = 1;
            SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
            aux1{i_av} = str2double(SetupTES.Multi_Value.String);
            if i_av == averages
                IVmeasure.vout(i) = mean(cell2mat(aux1));
            end
        end
        % Read I real value
        SetupTES.SQ_Read_I.Value = 1;
        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
        pause(0.1);
        IVmeasure.ibias(i) = str2double(SetupTES.SQ_realIbias.String);
        
        % Actualizamos el gráfico
        Ch = findobj(SetupTES.Result_Axes,'Type','Line');
        delete(Ch);
        plot(SetupTES.Result_Axes,IVmeasure.ibias(1:i),IVmeasure.vout(1:i),'Marker','o','Color',[0 0.447 0.741]);
        hold(SetupTES.Result_Axes,'on');
        xlabel(SetupTES.Result_Axes,'Ibias (uA)')
        ylabel(SetupTES.Result_Axes,'Vout (V)');
        set(SetupTES.Result_Axes,'fontsize',12);
        refreshdata(SetupTES.Result_Axes);
        axis(SetupTES.Result_Axes,'tight');
        
    end
    IVmeasure.Tbath = nan;
    data(:,1) = IVmeasure.ibias;
    data(:,2) = IVmeasure.vout;
    
    j = size(data,2);
    switch j
        case 2
            IVmeasure.ibias = data(:,1)*1e-6;
            if data(1,1) == 0
                IVmeasure.vout = data(:,2)-data(1,2);
            else
                IVmeasure.vout = data(:,2)-data(end,2);
            end
        case 4
            IVmeasure.ibias = data(:,2)*1e-6;
            if data(1,2) == 0
                IVmeasure.vout = data(:,4)-data(1,4);
            else
                IVmeasure.vout = data(:,4)-data(end,4);
            end
    end
    
    %% Calcular el valor de Ib de acuerdo con Rn
    val = polyfit(IVmeasure.ibias(1:3),IVmeasure.vout(1:3),1);
    mN = val(1);
    val = polyfit(IVmeasure.ibias(end-2:end),IVmeasure.vout(end-2:end),1);
    mS = val(1);
    SetupTES.Circuit.mN.Value = mN;
    SetupTES.Circuit.mS.Value = mS;
    SetupTES.Circuit.Rpar.Value =(SetupTES.Circuit.Rf.Value*SetupTES.Circuit.invMf.Value/(SetupTES.Circuit.mS.Value*SetupTES.Circuit.invMin.Value)-1)*SetupTES.Circuit.Rsh.Value;
    SetupTES.Circuit.Rn.Value=(SetupTES.Circuit.Rsh.Value*SetupTES.Circuit.Rf.Value*SetupTES.Circuit.invMf.Value/(SetupTES.Circuit.mN.Value*SetupTES.Circuit.invMin.Value)-SetupTES.Circuit.Rsh.Value-SetupTES.Circuit.Rpar.Value);
    
    TESDATA.circuit = TES_Circuit;
    TESDATA.circuit = TESDATA.circuit.Update(SetupTES.Circuit);
    IVCurveSet = TES_IVCurveSet;
    IVCurveSet = IVCurveSet.Update(IVmeasure);
    TESDATA.TES.n = [];
    IVset = IVCurveSet.GetIVTES(TESDATA);
else
    figure(SetupTES.SetupTES)
    IVset = handles.SetupTES.IVset;
end
for Ri = 1:length(Conf.FieldScan.Rn)
    clear data;
    Conf.FieldScan.Ibias = BuildIbiasFromRp(IVset,Conf.FieldScan.Rn(Ri));  %%%%%%
    handles.Field_Ibias.String = num2str(Conf.FieldScan.Ibias);
    
    % Calibramos la fuente de corriente
    SetupTES.CurSource_Cal.Value = 1;
    SetupTEScontrolers('CurSource_Cal_Callback',SetupTES.CurSource_Cal,[],guidata(SetupTES.CurSource_Cal))
    
    % Ponemos el Squid en Estado Normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(Conf.FieldScan.Ibias),guidata(SetupTES.SQ_TES2NormalState));
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Ponemos el valor de Ibias en el Squid
    SetupTES.SQ_Ibias.String = num2str(Conf.FieldScan.Ibias);
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
    
    % Leemos el valor real de Ibias en el Squid
    SetupTES.SQ_Read_I.Value = 1;
    SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
    Ireal = str2double(SetupTES.SQ_realIbias.String);
    
    SetupTES.CurSource_I_Units.Value = 1;
    SetupTES.CurSource_I.String = num2str(Conf.FieldScan.BVvalues(1)*1e-6);  % Se pasan las corrientes en amperios
    SetupTES.CurSource_Set_I.Value = 1;
    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
    SetupTES.CurSource_OnOff.Value = 1;
    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
    jj = 1;
    for j = 1:length(Conf.FieldScan.BVvalues)
        
        if j > 1
            % Ponemos el valor de corriente en la fuente
            SetupTES.CurSource_I_Units.Value = 1;
            SetupTES.CurSource_I.String = num2str(Conf.FieldScan.BVvalues(j)*1e-6);  % Se pasan las corrientes en amperios
            SetupTES.CurSource_Set_I.Value = 1;
            SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
        end
        if jj == 1
            pause(1.5);
        else
            pause(0.5);
        end
        
        averages = 1;
        for i_av = 1:averages
            SetupTES.Multi_Read.Value = 1;
            SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
            aux1{i_av} = str2double(SetupTES.Multi_Value.String);
            if i_av == averages
                Vdc = mean(cell2mat(aux1));
            end
        end
        
        data(jj,1) = now;
        data(jj,2) = Conf.FieldScan.BVvalues(j); %*1e-6;
        data(jj,3) = Ireal; %%%Vout
        data(jj,4) = Vdc;
        
        
        % Actualizamos el gráfico
        Ch = findobj(SetupTES.Result_Axes,'Type','Line');
        delete(Ch);
        plot(SetupTES.Result_Axes,data(1:jj,2),data(1:jj,4),'Marker','o','Color',[0 0.447 0.741],'DisplayName',num2str(Conf.FieldScan.Rn(Ri)));
        hold(SetupTES.Result_Axes,'on');
        xlabel(SetupTES.Result_Axes,'Bfield (uA)')
        ylabel(SetupTES.Result_Axes,'Vout (V)');
        set(SetupTES.Result_Axes,'fontsize',12);
        refreshdata(SetupTES.Result_Axes);
        axis(SetupTES.Result_Axes,'tight');
        
        %         pause(0.2)
        jj = jj+1;
    end
end
% Desactivamos la salida de corriente de la fuente
SetupTES.CurSource_OnOff.Value = 0;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

%%%
[val, ind] = max(data(:,4));
if Conf.FieldScan.Ibias > 0
    OptField.p = data(ind,4);
else
    OptField.n = data(ind,4);
end

plot(SetupTES.Result_Axes,data(ind,2),val,'*','Color','g','MarkerSize',10);

B = data(:,2);
V = data(:,4);

file = strcat('BVscan',num2str(Ireal,'%1.1f'),'uA_',num2str(Temp*1e3,'%1.1f'),'mK');
save([handles.Barrido_Campo_Dir file],'B','V');
save([handles.Barrido_Campo_Dir file '.txt'],'data','-ascii');

function I_Criticas_Carlos(Temp,BfieldValues,Conf,SetupTES,handles)

figure(SetupTES.SetupTES)
cla(SetupTES.Result_Axes);
hold(SetupTES.Result_Axes,'on');
xlabel(SetupTES.Result_Axes,'Bfield(uA)');
ylabel(SetupTES.Result_Axes,'Ibias(uA)');
% Ponemos el valor de corriente en la fuente
SetupTES.CurSource_I_Units.Value = 1;
SetupTES.CurSource_I.String = num2str(BfieldValues(1)*1e-6);  % Se pasan las corrientes en amperios
SetupTES.CurSource_Set_I.Value = 1;
SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
SetupTES.CurSource_OnOff.Value = 1;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));


SetupTES.SQ_Reset_Closed_Loop.Value = 1;
SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',...
    SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));

step = 0.1;

for i = 1:length(BfieldValues)
    
    SetupTES.CurSource_I_Units.Value = 1;
    SetupTES.CurSource_I.String = num2str(BfieldValues(i)*1e-6);  % Se pasan las corrientes en amperios
    SetupTES.CurSource_Set_I.Value = 1;
    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
    pause(1);
    
    if i < 4
        i0 = [1 1];
    else
        mmp = (ICpairs(i-1).p-ICpairs(i-3).p)/(BfieldValues(i-1)-BfieldValues(i-3));
        mmn = (ICpairs(i-1).n-ICpairs(i-3).n)/(BfieldValues(i-1)-BfieldValues(i-3));
        icnext_p = ICpairs(i-1).p + mmp*(BfieldValues(i)-BfieldValues(i-1));
        icnext_n = ICpairs(i-1).n + mmn*(BfieldValues(i)-BfieldValues(i-1));
        ic0_p = 0.9*icnext_p;
        ic0_n = 0.9*icnext_n;
        tempvalues = 0:step:500;%%%array de barrido en corriente
        ind_p = find(tempvalues <= abs(ic0_p));
        ind_n = find(tempvalues <= abs(ic0_n));
        try
            i0 = [ind_p(end) ind_n(end)];%%%Calculamos el índice que corresponde a la corriente para empezar el barrido
        catch
            i0 = [1 1];
        end
    end
    try
        aux = measure_IC_Pair_autom(step,i0,BfieldValues(i),SetupTES);
        ICpairs(i).p = aux.p;
        ICpairs(i).n = aux.n;
        ICpairs(i).B = BfieldValues(i);
        step = min(2,max(0.1,aux.p/20));%por si es cero.
    catch
        warning('error de lectura')
        pause(1)
        ICpairs(i).p = nan;
        ICpairs(i).n = nan;
        ICpairs(i).B = BfieldValues(i);
        %continue;
    end
    
    hf = findobj(SetupTES.Result_Axes,'DisplayName','Temporal');
    delete(hf);
    HL = findobj(SetupTES.Result_Axes,'DisplayName','Final_Temporal');
    delete(HL);
    plot(SetupTES.Result_Axes,BfieldValues(1:i),[ICpairs.p],'ro-',BfieldValues(1:i),[ICpairs.n],'ro-','DisplayName','Final');
end
FileStr = ['ICpairs' num2str(Temp*1e3,'%1.1f') 'mK.mat'];
save([handles.ICs_Dir FileStr],'ICpairs');
data(:,1) = ICpairs(i).B;
data(:,2) = ICpairs(i).p;
data(:,3) = ICpairs(i).n;
save([handles.ICs_Dir 'ICpairs' num2str(Temp*1e3,'%1.1f') '.txt'],'data','-ascii');

SetupTES.CurSource_I_Units.Value = 1;
SetupTES.CurSource_I.String = num2str(0*1e-6);  % Se pasan las corrientes en amperios
SetupTES.CurSource_Set_I.Value = 1;
SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
SetupTES.CurSource_OnOff.Value = 0;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

function ICpair = measure_IC_Pair_autom(step,i0,B,SetupTES)

Ivalues = 0:step:500;
Rf = SetupTES.Circuit.Rf.Value;
THR = 1;

for jj = 1:2 % barrido positivo y negativo
    
    if jj == 2
        Ivalues = -Ivalues;
        IV = [];
    end
    
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',...
        SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Set Ibias to zero value in order to impose TES's Superconductor State
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Ibias.String = num2str(Ivalues(1));
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I, [], guidata(SetupTES.SQ_Set_I));
    
    a = SetupTES.Squid.Read_Current_Value;
    IV.ic(1) = a.Value;
    pause(1);
    [~, v] = SetupTES.Multi.Read;
    IV.vc(1) = v.Value;
    vout1 = IV.vc(1);
    
%     HL = findobj(handles.Result_Axes,'DisplayName','Temporal');
%     delete(HL);
    DataName = 'Temporal';
    plot(SetupTES.Result_Axes,B,IV.ic(1),'bo-','DisplayName',DataName);
    
    for i = i0(jj)+1:length(Ivalues)
        % Set Ibias to zero value in order to impose TES's Superconductor State
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Ibias.String = num2str(Ivalues(i));
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I, [], guidata(SetupTES.SQ_Set_I));
        pause(0.5);
        a = SetupTES.Squid.Read_Current_Value;
        IV.ic(i) = a.Value;
        [~, v] = SetupTES.Multi.Read;
        IV.vc(i) = v.Value;
        vout2 = IV.vc(i);
    
%         HL = findobj(handles.Result_Axes,'DisplayName','Temporal');
%         delete(HL);
        DataName = 'Temporal';
        plot(SetupTES.Result_Axes,B,IV.ic(i),'bo-','DisplayName',DataName);    
        
        slope = (vout2 -vout1)/((Ivalues(i)-Ivalues(i-1))*1e-6)/Rf;
        if slope < THR
            break;
        end
        vout1 = vout2;
    end
    % Set Ibias to zero value in order to impose TES's Superconductor State
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Ibias.String = num2str(0);
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I, [], guidata(SetupTES.SQ_Set_I));
    
    if jj == 1
        ICpair.p = IV.ic(end-1);
    elseif jj == 2
        ICpair.n = IV.ic(end-1);
    end
    HL = findobj(SetupTES.Result_Axes,'DisplayName','Temporal');
    delete(HL);
    plot(SetupTES.Result_Axes,B,IV.ic(end-1),'ro-','DisplayName','Final_Temporal');  
end

function I_Criticas(Temp,BfieldValues,Conf,SetupTES,handles)


%
% Rf_popup = get(SetupTES.SQ_Rf,'Value');
% set(SetupTES.SQ_Rf,'Value',2); % 7e2 value
% SetupTEScontrolers('SQ_Calibration_Callback',SetupTES.SQ_Calibration,[],guidata(SetupTES.SQ_Calibration));

figure(SetupTES.SetupTES)
StrCond = {'p';'n'};
Ibvalues_step = 1;

% %                 % Reset Closed Loop
% SetupTES.SQ_Reset_Closed_Loop.Value = 1;
% SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
hold(SetupTES.Result_Axes,'on');



% Ponemos el valor de corriente en la fuente
SetupTES.CurSource_I_Units.Value = 1;
SetupTES.CurSource_I.String = num2str(BfieldValues(1)*1e-6);  % Se pasan las corrientes en amperios
SetupTES.CurSource_Set_I.Value = 1;
SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
SetupTES.CurSource_OnOff.Value = 1;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

delete(findobj(SetupTES.Result_Axes,'Type','Line'));

LNCS = 0;
Ibvalues = 0;
j = 1;
while j < length(BfieldValues)+1
    
    xlabel(SetupTES.Result_Axes2,'Icritical(\mu A)');
    ylabel(SetupTES.Result_Axes2,'V out(V)');
    SetupTES.Result_Axes2.Visible = 'on';
    hold(SetupTES.Result_Axes2,'on');
    cond = 1;
    while cond < 3
        cla(SetupTES.Result_Axes2);
        %     clear data;
        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
        pause(0.2);
        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
        
        clear data;
        if LNCS
            mag_ConnectLNCS(mag);
            mag_setLNCSImag(mag,0);
        end
        
        % Set Ibias to zero value in order to impose TES's Superconductor State
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Ibias.String = num2str(0);
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I, [], guidata(SetupTES.SQ_Set_I));
        
        if Ibvalues ~= 0
            if cond == 1
                Ibvalues = max(abs(Ibvalues)*0.80,0);
            else
                Ibvalues = min(-abs(Ibvalues)*0.60,0);
            end
            if abs(Ibvalues) < 20
                Ibvalues = 0;
            end
        end
        
        if j > 1
            SetupTES.CurSource_I_Units.Value = 1;
            SetupTES.CurSource_I.String = num2str(BfieldValues(j)*1e-6);  % Se pasan las corrientes en amperios
            SetupTES.CurSource_Set_I.Value = 1;
            SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
        end
        
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Ibias.String = num2str(Ibvalues);
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        
        Ch = findobj(SetupTES.Result_Axes,'DisplayName','Temporal');
        delete(Ch);
        jj = 1;
        
        bwhile = 0;
        c = true;
        while c
            if abs(Ibvalues) > 500 % Repetir la medida con la fuente de LNCS
                eval(['ICpairs(j).' StrCond{cond} ' = IVmeasure.ibias(jj-1);'])
                data(jj,4) = IVmeasure.ibias(jj-1);
                data(jj,2) = BfieldValues(j);
                clear IVmeasure;
                LNCS = 0;
                break;
            end
            
            SetupTES.SQ_Ibias_Units.Value = 3;
            SetupTES.SQ_Ibias.String = num2str(Ibvalues);
            SetupTES.SQ_Set_I.Value = 1;
            SetupTES.Squid.Set_Current_Value(Ibvalues)
            if jj == 1
                pause(1.5);
            end
            SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
            
            a = SetupTES.Squid.Read_Current_Value;
            IVmeasure.ibias(jj) = a.Value;
            pause(0.6)
            [~, v] = SetupTES.Multi.Read;
            IVmeasure.vout(jj) = v.Value;
            
            data(jj,4) = IVmeasure.ibias(jj);
            data(jj,2) = BfieldValues(j);
            
            hl = findobj(SetupTES.Result_Axes,'DisplayName','Temporal');
            delete(hl);
            DataName = 'Temporal';
            plot(SetupTES.Result_Axes,data(1:jj,2),data(1:jj,4),'bo','DisplayName',DataName);
            plot(SetupTES.Result_Axes2,IVmeasure.ibias(jj),IVmeasure.vout(jj),'ro-');
            %             SetupTEScontrolers('ManagingData2Plot(data,DataName,SetupTES,SetupTES.IC_Range)');
            
            if jj > 2 % Se descarta el primer valor
                slope = median(diff(IVmeasure.vout(jj-1:jj))./diff(IVmeasure.ibias(jj-1:jj)*1e-6));
                
                if slope < SetupTES.Circuit.mS.Value*0.5 % SlopeTH < 1 estado normal
                    if slope < 0
                        if jj == 4
                            jj = 1;
                            clear IVmeasure;
                            %                             Ibvalues_step = 0.01;
                            try
                                Ibvalues = eval(['ICpairs(j-1).' StrCond{cond}])*0.8;
                            catch
                                Ibvalues = 0;
                            end
                            LNCS = 0;
                            bwhile = 1;
                            break;
                        else
                            eval(['ICpairs(j).' StrCond{cond} ' = IVmeasure.ibias(jj-1);'])
                            data(jj,4) = IVmeasure.ibias(jj);
                            data(jj,2) = BfieldValues(j);
                            
                            clear IVmeasure;
                            LNCS = 0;
                            if cond == 2
                                Ibvalues_step = abs(Ibvalues*1.05);
                            end
                            break;
                        end
                    else
                        if jj < 5
                            jj = 1;
                            clear IVmeasure;
                            Ibvalues_step = 0.01;
                            Ibvalues = 0;
                            LNCS = 0;
                            bwhile = 1;
                            break;
                        end
                        eval(['ICpairs(j).' StrCond{cond} ' = IVmeasure.ibias(jj-1);'])
                        data(jj,4) = IVmeasure.ibias(jj);
                        data(jj,2) = BfieldValues(j);
                        if cond == 2
                            Ibvalues_step = abs(Ibvalues*0.05);
                        end
                        %                         Ibvalues_step = 1;
                        clear IVmeasure;
                        LNCS = 0;
                        break;
                    end
                else
                    data(jj,4) = IVmeasure.ibias(jj);
                    data(jj,2) = BfieldValues(j);
                    jj = jj+1;
                    
                    if cond == 1
                        Ibvalues = Ibvalues+Ibvalues_step;
                    else
                        Ibvalues = Ibvalues-Ibvalues_step;
                    end
                end
                
            else
                jj = jj+1;
                if cond == 1
                    Ibvalues = Ibvalues+Ibvalues_step;
                else
                    Ibvalues = Ibvalues-Ibvalues_step;
                end
            end
        end
        if bwhile
            continue;
        end
        ICpairs(j).B = BfieldValues(j);
        %         hf = findobj(SetupTES.Result_Axes,'DisplayName','Final');
        %         delete(hf);
        plot(SetupTES.Result_Axes,[ICpairs(1:j).B],eval(['[ICpairs(1:j).' StrCond{cond} ']']),'ro-','DisplayName','Final')
        cond = cond+1;
    end % End Bfield values
    if bwhile
        continue;
    end
    j = j+1;
    
end % End Cond (positive or negative ibias)
FileStr = ['ICpairs' num2str(Temp*1e3) 'mK.mat'];
save([handles.Barrido_Campo_Dir FileStr],'ICpairs');

file = strcat('Ic_',num2str(Temp*1e3,'%1.1f'),'mK_',StrCond{cond},'_matlab.txt');
save([handles.ICs_Dir file],'data','-ascii');
clear ICpairs

if LNCS
    mag_setLNCSImag(mag,0);
    mag_DisconnectLNCS(mag);
end

% Desactivamos la salida de corriente de la fuente
SetupTES.CurSource_OnOff.Value = 0;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

function Medir_Zw_Noise(Temp,Opt,IZvalues,Path,Conf,SetupTES,handles)

figure(SetupTES.SetupTES)
if Conf.TF.Zw.DSA.On || Conf.TF.Noise.DSA.On
    % Calibracion del HP
    SetupTES.DSA.Calibration;
    
    
    % Ponemos el TES en estado normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(1),guidata(SetupTES.SQ_TES2NormalState));
    
    for i = 1:length(IZvalues)
        % For para cada IZvalue (Ibias)
        try
        
        % Reseteamos el lazo
        % Reset Closed Loop
        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
        
        % Ponemos la corriente para fijar el punto de operacion del Squid
        % Ponemos el valor de Ibias en el Squid
        
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Ibias.String = num2str(IZvalues(i));
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        
        % Leemos la corriente real del Squid
        % Read I real value
        SetupTES.SQ_Read_I.Value = 1;
        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
        pause(0.1);
        Itxt = SetupTES.SQ_realIbias.String;
        catch
            continue;
        end
        
        if Opt == 1 || Opt == 3 % Se mide el Zw
            
            if Conf.TF.Zw.DSA.On
                
                switch handles.DSA_TF_Zw_Menu.Value
                    case 1 % Sweept sine
                        if handles.DSA_Input_Amp_Units.Value ~= 4
                            handles.DSA_Input_Amp_Units.Value = 2;  % mV
                            IbvaluesConf('DSA_Input_Amp_Callback',handles.DSA_Input_Amp,[],handles);
                            Amp = round(str2double(handles.DSA_Input_Amp.String));
                        else
                            Amp = abs(round(IZvalues(i)*1e1*str2double(handles.DSA_Input_Amp.String)));
                        end
                        SetupTES.DSA = SetupTES.DSA.SineSweeptMode(Amp);
                        
                    case 2 % Fixed sine
                        handles.DSA_Input_Freq_Units.Value = 1;  % Hz
                        IbvaluesConf('DSA_Input_Freq_Callback',handles.DSA_Input_Freq,[],handles);
                        Freq = str2double(handles.DSA_Input_Freq.String);
                        if handles.DSA_Input_Amp_Units.Value ~= 4
                            handles.DSA_Input_Amp_Units.Value = 2;  % mV
                            IbvaluesConf('DSA_Input_Amp_Callback',handles.DSA_Input_Amp,[],handles);
                            Amp = round(str2double(handles.DSA_Input_Amp.String));
                        else
                            Amp = abs(round(IZvalues(i)*1e1*str2double(handles.DSA_Input_Amp.String)));
                        end
                        SetupTES.DSA = SetupTES.DSA.FixedSine(Amp,Freq);
                        
                    case 3 % White noise
                        if handles.DSA_Input_Amp_Units.Value ~= 4
                            handles.DSA_Input_Amp_Units.Value = 2;  % mV
                            IbvaluesConf('DSA_Input_Amp_Callback',handles.DSA_Input_Amp,[],handles);
                            Amp = round(str2double(handles.DSA_Input_Amp.String));
                        else
                            Amp = abs(round(IZvalues(i)*1e1*str2double(handles.DSA_Input_Amp.String)));
                        end
                        SetupTES.DSA = SetupTES.DSA.WhiteNoise(Amp);
                        
                end
                
                [SetupTES.DSA, datos] = SetupTES.DSA.Read;
                
                % Guardamos los datos en un fichero
                file = strcat('TF_',Itxt,'uA','.txt');
                save([Path file],'datos','-ascii');%salva los datos a fichero.
            end
        end
        
        if Opt == 2 || Opt == 3 % Se mide el Ruido
            if Conf.TF.Noise.DSA.On
                
                SetupTES.DSA = SetupTES.DSA.NoiseMode;
                [SetupTES.DSA, datos] = SetupTES.DSA.Read;
                
                % Guardamos los datos en un fichero
                file = strcat('HP_noise_',Itxt,'uA','.txt');
                save([Path file],'datos','-ascii');%salva los datos a fichero.
            end
        end
        
    end
end

if Conf.TF.Zw.PXI.On || Conf.TF.Noise.PXI.On
    
    % Ponemos el TES en estado normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(1),guidata(SetupTES.SQ_TES2NormalState));
    
    for i = 1:length(IZvalues)
        % For para cada IZvalue (Ibias)
        try
        % Reseteamos el lazo
        % Reset Closed Loop
        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
        
        % Ponemos la corriente para fijar el punto de operacion del Squid
        % Ponemos el valor de Ibias en el Squid
        
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Ibias.String = num2str(IZvalues(i));
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        
        % Leemos la corriente real del Squid
        % Read I real value
        SetupTES.SQ_Read_I.Value = 1;
        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
        pause(0.1);
        Itxt = SetupTES.SQ_realIbias.String;
        catch
            continue;
        end
        
        % Reseteamos el lazo
        % Reset Closed Loop
        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
        
        if Opt == 1 || Opt == 3 % Se mide el Zw
            if Conf.TF.Zw.PXI.On
                
                SetupTES.PXI.AbortAcquisition;
                SetupTES.PXI = SetupTES.PXI.TF_Configuration;
                
                if handles.PXI_Input_Amp_Units == 4 % Porcentaje de Ibias
                    %                 Ireal = SetupTES.Squid.Read_Current_Value; % Devuelve el valor siempre en uA
                    excitacion = abs(round(IZvalues(i)*1e1*str2double(handles.PXI_Input_Amp.String)));
                else
                    handles.PXI_Input_Amp_Units.Value = 2;
                    excitacion = round(str2double(handles.PXI_Input_Amp.String));
                end
                
                SetupTES.DSA.SourceOn;
                SetupTES.DSA.WhiteNoise(excitacion);
                
                [data, ~] = SetupTES.PXI.Get_Wave_Form;
                
                sk = skewness(data);
                while abs(sk(3)) > SetupTES.PXI.Options.Skewness
                    [data,~] = SetupTES.PXI.Get_Wave_Form;
                    sk = skewness(data);
                end
                [txy,freqs] = tfestimate(data(:,2),data(:,3),[],[],2^14,SetupTES.PXI.ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
                n_avg = SetupTES.PXI.Options.NAvg;
                for i = 1:n_avg-1
                    [data,~] = SetupTES.PXI.Get_Wave_Form;
                    sk = skewness(data);
                    while abs(sk(3)) > SetupTES.PXI.Options.Skewness
                        [data,~] = SetupTES.PXI.Get_Wave_Form;
                        sk = skewness(data);
                    end
                    aux = tfestimate(data(:,2),data(:,3),[],[],2^14,SetupTES.PXI.ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
                    txy = txy+aux;
                end
                txy = txy/n_avg;
                txy = medfilt1(txy,40);
                datos = [freqs real(txy) imag(txy)];
                SetupTES.DSA.SourceOff;
                
                % Guardamos los datos en un fichero
                file = strcat('PXI_TF_',Itxt,'uA','.txt');
                save([Path file],'datos','-ascii');%salva los datos a fichero.
            end
        end
        if Opt == 2 || Opt == 3
            if Conf.TF.Noise.PXI.On
                
                SetupTES.PXI.AbortAcquisition;
                SetupTES.PXI = SetupTES.PXI.Noise_Configuration;
                pause(1);
                
                [data, ~] = SetupTES.PXI.Get_Wave_Form;
                
                sk = skewness(data);
                while abs(sk(3)) > SetupTES.PXI.Options.Skewness
                    [data,~] = SetupTES.PXI.Get_Wave_Form;
                    sk = skewness(data);
                end
                [psd,freq] = PSD(data);
                clear datos;
                datos(:,1) = freq;
                datos(:,2) = sqrt(psd);
                n_avg = SetupTES.PXI.Options.NAvg;
                for jj = 1:n_avg-1%%%Ya hemos adquirido una.
                    [data, ~] = SetupTES.PXI.Get_Wave_Form;
                    [psd,freq] = PSD(data);
                    clear aux;
                    aux(:,1) = freq;
                    aux(:,2) = sqrt(psd);
                    datos(:,2) = datos(:,2)+aux(:,2);
                end
                datos(:,2) = datos(:,2)/n_avg;
                
                % Guardamos los datos en un fichero
                file = strcat('PXI_noise_',Itxt,'uA','.txt');
                save([Path file],'datos','-ascii');%salva los datos a fichero.
            end
        end
    end
end

function Medir_Pulsos(Temp,Conf,IZvalues,Path,SetupTES,handles)

figure(SetupTES.SetupTES)
% Ponemos el TES en estado normal
SetupTES.SQ_TES2NormalState.Value = 1;
SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(1),guidata(SetupTES.SQ_TES2NormalState));

for i = 1:length(IZvalues)
    % For para cada IZvalue (Ibias)
    
    % Reseteamos el lazo
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Ponemos la corriente para fijar el punto de operacion del Squid
    % Ponemos el valor de Ibias en el Squid
    SetupTES.SQ_Ibias.String = num2str(IZvalues(i));
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
    
    % Leemos la corriente real del Squid
    % Read I real value
    SetupTES.SQ_Read_I.Value = 1;
    SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
    pause(0.1);
    Itxt = SetupTES.SQ_realIbias.String;
    
    
    SetupTES.PXI.AbortAcquisition;
    SetupTES.PXI = SetupTES.PXI.Pulses_Configuration;
    
    set(get(SetupTES.PXI.ObjHandle,'triggering'),'trigger_source','NISCOPE_VAL_EXTERNAL');
    [datos, WfmI, TimeLapsed] = SetupTES.PXI.Get_Wave_Form;
    
    % Guardamos los datos en un fichero
    file = strcat('PXI_Pulso_',Itxt,'uA','.txt');
    save([Path file],'datos','-ascii');%salva los datos a fichero.
    
    
end


