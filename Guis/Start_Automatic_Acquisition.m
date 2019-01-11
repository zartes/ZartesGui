function Start_Automatic_Acquisition(handles, SetupTES, Conf)

handles.AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
if ~ischar(handles.AQ_dir)
    return;
end
% Generamos las carpetas donde iran las medidas

PathStr = {'Barrido_Campo';'ICs';'IVs';'Negative_Bias'};
for i = 1:length(PathStr)
    eval(['handles.' PathStr{i} '_Dir = [handles.AQ_dir filesep ''' PathStr{i} ''' filesep];']);
    if exist(eval(['handles.' PathStr{i} '_Dir']),'dir') == 0
        [Succ, Message] = mkdir(eval(['handles.' PathStr{i} '_Dir']));
        if ~Succ
            warndlg(Message,'ZarTES v1.0');
            msgbox('Acquisition Aborted','ZarTES v1.0');
        end
    end
end
    

for NSummary = 1:size(Conf.Summary,1) 
    
    Temp = Conf.Summary{NSummary,1};    
    AjustarTemperatura(Temp,Conf,SetupTES,handles)
            
    if strcmp(Conf.Summary{NSummary,2},'Yes')    % Si se mide o on
        Bfield = FieldScan(Temp,Conf,SetupTES,handles);  % Se obtiene Bfield.p y Bfield.n
    elseif ~Conf.BField.FromScan
        Bfield.p = Conf.BField.P;
        Bfield.n = Conf.BField.N;
    end
    if Conf.BField.Symmetric
        Bfield.n = Bfield.p;
    end
    
    if strcmp(Conf.Summary{NSummary,3},'Yes')    % Si se mide o on
        try
            I_Criticas(Temp,Bfield.n,Conf,SetupTES,handles);        
        end
        try
            I_Criticas(Temp,Bfield.p,Conf,SetupTES,handles);
        end
        
        I_Criticas(Temp,Conf.BField_IC.BVvalues,Conf,SetupTES,handles);
    end
        
    if strcmp(Conf.Summary{NSummary,4},'Yes')    % Si se mide o on
        [IVsetP, IVsetN] = Medir_IV(Temp,Bfield,SetupTES,handles);
    end                                
        
    if strcmp(Conf.Summary{NSummary,5},'Yes')&&strcmp(Conf.Summary{NSummary,6},'Yes')    % Si se mide o on        
        Opt = 3; % Zw y Ruido (3)                
    elseif strcmp(Conf.Summary{NSummary,5},'Yes')&&strcmp(Conf.Summary{NSummary,6},'No')        
        Opt = 1; % Sólo Zw (1)        
    elseif strcmp(Conf.Summary{NSummary,5},'No')&&strcmp(Conf.Summary{NSummary,6},'Yes')
        Opt = 2; % Sólo Ruido (2)
    end
    if strcmp(Conf.Summary{NSummary,5},'Yes')||strcmp(Conf.Summary{NSummary,6},'Yes')  
        
        handles.Positive_Path = [handles.AQ_dir filesep num2str(Temp*1e3) 'mK' filesep];
        if exist(handles.Positive_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Positive_Path);
            if ~Succ
                warndlg(Message,'ZarTES v1.0');
                msgbox('Acquisition Aborted','ZarTES v1.0');
            end
        end
        handles.Negative_Path = [handles.Negative_Bias_Dir num2str(Temp*1e3) 'mK' filesep];
        if exist(handles.Positive_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Positive_Path);
            if ~Succ
                warndlg(Message,'ZarTES v1.0');
                msgbox('Acquisition Aborted','ZarTES v1.0');
            end
        end
        
        % Es esencial que hayamos medido al menos una curva IV positiva y
        % otra negativa
            
        IZvalues.P = BuildIbiasFromRp(IVsetP,Conf.TF.Zw.rpp);
        IZvalues.N = BuildIbiasFromRp(IVsetN,Conf.TF.Zw.rpn);
        
        Medir_Zw_Noise(Temp,Opt,IZvalues.P,handles.Positive_Path,Conf,SetupTES,handles);        
        Medir_Zw_Noise(Temp,Opt,IZvalues.N,handles.Negative_Path,Conf,SetupTES,handles);
    end
    
        
    if strcmp(Conf.Summary{NSummary,7},'Yes')    % Si se mide o on
        handles.Positive_Pulse_Path = [handles.AQ_dir filesep num2str(Temp*1e3) 'mK' filesep 'Pulsos' filesep];
        if exist(handles.Positive_Pulse_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Positive_Pulse_Path);
            if ~Succ
                warndlg(Message,'ZarTES v1.0');
                msgbox('Acquisition Aborted','ZarTES v1.0');
            end
        end
        handles.Negative_Pulse_Path = [handles.Negative_Bias_Dir num2str(Temp*1e3) 'mK' filesep 'Pulsos' filesep];
        if exist(handles.Negative_Pulse_Path,'dir') == 0
            [Succ, Message] = mkdir(handles.Negative_Pulse_Path);
            if ~Succ
                warndlg(Message,'ZarTES v1.0');
                msgbox('Acquisition Aborted','ZarTES v1.0');
            end
        end
        Medir_Pulsos(Temp,Conf,IZvalues.P,handles.Positive_Path,SetupTES,handles);
        Medir_Pulsos(Temp,Conf,IZvalues.N,handles.Negative_Pulse_Path,SetupTES,handles);
        
%         %%%% Falta la parte de medir N Pulsos a un Rn dado
%         IZvalues.P = BuildIbiasFromRp(IVsetP,Conf.Pulse.PXI.Rn);
%         Medir_Pulsos(Temp,Conf,IZvalues.P,handles.Positive_Path,SetupTES,handles);
        %%%%
    end                        
    
end

function AjustarTemperatura(Temp,Conf,SetupTES,handles)




SetupTES.vi_IGHChangeSettings.Run(1)
SetupTES.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
while strcmp(SetupTES.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
% handles.vi_PromptForT.Run(1);
SetupTES.vi_PromptForT.SetControlValue('Set T',Temp)
% 
pause(0.4)
SetupTES.vi_PromptForT.SetControlValue('Set T',Temp)
SetupTES.vi_PromptForT.SetControlValue('OK',1)

set(SetupTES.SetPt,'String',num2str(Temp));

RGB = [linspace(120,255,100)' sort(linspace(50,170,100),'descend')' 50*ones(100,1)]./255;

Error = nan(10,1);
c = true;
j = 1;
h = waitbar(0,'Setting Mixing Chamber Temperature','WindowStyle','Modal','Name','ZarTES v1.0');
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
    
    if nanmedian(Error) < 0.4  % Cuando la temperatura alcanza un valor con un error relativo menor al 0.4%
       c = false; 
    end
    j = max(mod(j+1,10),1);
    if ishandle(h);
        waitbar(j/10,h,['SetPt: ' num2str(Set_Pt) ' - M/C: ' num2str(T_MC)]);
    end
    pause(0.2);
end
close(h);


function OptField = FieldScan(Temp,Conf,SetupTES,handles)

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
    val = polyfit(IVmeasure.ibias(1:10),IVmeasure.vout(1:10),1);
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
        
        pause(0.5)
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
        
        pause(0.2)
        jj = jj+1;
    end
end
% Desactivamos la salida de corriente de la fuente
SetupTES.CurSource_OnOff.Value = 0;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

%%%
[val, ind] = max(abs(data(:,4)));
if Conf.FieldScan.Ibias > 0    
    OptField.p = data(ind,4);
else
    OptField.n = data(ind,4);
end

plot(SetupTES.Result_Axes,data(ind,2),val,'*','Color','g','MarkerSize',10);

B = data(:,2);
V = data(:,4);

file = strcat('BVscan',num2str(Temp*1e3),'mK');
save([handles.Barrido_Campo_Dir file],'B','V');


function I_Criticas(Temp,BfieldValues,Conf,SetupTES,handles)



Rf_popup = get(SetupTES.SQ_Rf,'Value');
set(SetupTES.SQ_Rf,'Value',2); % 7e2 value
SetupTEScontrolers('SQ_Calibration_Callback',SetupTES.SQ_Calibration,[],guidata(SetupTES.SQ_Calibration));


StrCond = {'p';'n'};
Ibvalues_step = 0.25;

%                 % Reset Closed Loop
SetupTES.SQ_Reset_Closed_Loop.Value = 1;
SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));

for cond = 1:2
    clear data;
    
    % Ponemos el valor de corriente en la fuente
    SetupTES.CurSource_I_Units.Value = 1;
    SetupTES.CurSource_I.String = num2str(BfieldValues(1)*1e-6);  % Se pasan las corrientes en amperios
    SetupTES.CurSource_Set_I.Value = 1;
    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
    SetupTES.CurSource_OnOff.Value = 1;
    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
    SetupTES.SQ_Ibias.String = num2str(0);
    SetupTES.SQ_Ibias_Units.Value = 3;
    SetupTES.SQ_Set_I.Value = 1;
    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    pause(0.2)
    LNCS = 0;
    
    for j = 1:length(BfieldValues)
        clear data;
        if LNCS
            mag_ConnectLNCS(mag);
            mag_setLNCSImag(mag,0);
        end
        Ibvalues = 0;
        if j > 1
            
            SetupTES.CurSource_I_Units.Value = 1;
            SetupTES.CurSource_I.String = num2str(BfieldValues(j)*1e-6);  % Se pasan las corrientes en amperios
            SetupTES.CurSource_Set_I.Value = 1;
            SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
        end
        
        SetupTES.SQ_Ibias.String = num2str(Ibvalues);
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        
        % Read I real value
        SetupTES.SQ_Read_I.Value = 1;
        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
        pause(0.4)
        
        jj = 1;
        % Adquirimos Curvas I-V para determinar el Ibias crítica en el que pasa de superconductor a estado normal
        SetupTES.Multi_Read.Value = 1;
        SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
        c = true;
        while c
            if abs(Ibvalues) > 500 % Repetir la medida con la fuente de LNCS
                clear IVmeasure;
                j = j -1;      
                LNCS = 1;
                break;
            end
            
            SetupTES.SQ_Ibias_Units.Value = 3;
            SetupTES.SQ_Set_I.Value = 1;
            SetupTES.Squid.Set_Current_Value(Ibvalues)
            SetupTES.SQ_Ibias.String = num2str(Ibvalues);
            
            [~, v] = SetupTES.Multi.Read;
            IVmeasure.vout(jj) = v.Value;
            
            a = SetupTES.Squid.Read_Current_Value;
            IVmeasure.ibias(jj) = a.Value;
            pause(0.1)
            
            Ch = findobj(SetupTES.Result_Axes,'Type','Line');
            delete(Ch);
            plot(SetupTES.Result_Axes,IVmeasure.ibias,IVmeasure.vout,'Marker','o','Color',[0 0.447 0.741]);
            hold(SetupTES.Result_Axes,'on');
            xlabel(SetupTES.Result_Axes,'Ibias (uA)')
            ylabel(SetupTES.Result_Axes,'Vout (V)');
            set(SetupTES.Result_Axes,'fontsize',12);
            refreshdata(SetupTES.Result_Axes);
            axis(SetupTES.Result_Axes,'tight');
            
            if jj > 4 % Se descarta el primer valor
                slope = median(diff(IVmeasure.vout(jj-3:jj))./diff(IVmeasure.ibias(jj-3:jj)*1e-6));
            
                if slope < handles.SetupTES.Circuit.mS.Value*0.8 % SlopeTH < 1 estado normal
                    eval(['ICpairs(j).' StrCond{cond} ' = IVmeasure.ibias(jj-4);'])
                    data(jj,2) = IVmeasure.ibias(jj);
                    data(jj,4) = IVmeasure.vout(jj);
                    clear IVmeasure; 
                    LNCS = 0;
                    break;
                else
                    data(jj,2) = IVmeasure.ibias(jj);
                    data(jj,4) = IVmeasure.vout(jj);
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
        ICpairs(j).B = BfieldValues(j);
    end % End Bfield values
    FileStr = ['ICpairs' num2str(Temp*1e3) 'mK.mat'];
    save([handles.Barrido_Campo_Dir FileStr],'ICpairs');
    
    file = strcat('Ic_',Temp*1e3,'mK_',StrCond{cond},'_matlab.txt');
    save([handles.ICs_Dir file],'data','-ascii');
    clear ICpairs IVmeasure
end % End Cond (positive or negative ibias)

if LNCS
    mag_setLNCSImag(mag,0);
    mag_DisconnectLNCS(mag);
end

% Desactivamos la salida de corriente de la fuente
SetupTES.CurSource_OnOff.Value = 0;
SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));

set(SetupTES.SQ_Rf,'Value',Rf_popup); % 7e2 value
SetupTEScontrolers('SQ_Calibration_Callback',SetupTES.SQ_Calibration,[],guidata(SetupTES.SQ_Calibration));


function [IVsetP, IVsetN] = Medir_IV(Temp,Bfield,Conf,SetupTES,handles)


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
        Field = Bfield.p;
        IBvals = Ibvalues.p;
    else
        Field = Bfield.n;
        IBvals = Ibvalues.n;
    end
    
    SetupTES.CurSource_I_Units.Value = 1;
    SetupTES.CurSource_I.String = num2str(Field*1e-6);  % Se pasan las corrientes en amperios
    SetupTES.CurSource_Set_I.Value = 1;
    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
    SetupTES.CurSource_OnOff.Value = 1;
    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
    
    
    % Ponemos el Squid en Estado Normal
    SetupTES.SQ_TES2NormalState.Value = 1;
    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(1),guidata(SetupTES.SQ_TES2NormalState));
    % Reset Closed Loop
    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
    
    % Adquirimos una Curva I-V    
    i = 1;
    while abs(IBvals(i)) >= 0
        SetupTES.SQ_Ibias.String = num2str(IBvals(i));
        SetupTES.SQ_Ibias_Units.Value = 3;
        SetupTES.SQ_Set_I.Value = 1;
        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
        
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
                if slope_curr > nanmean(slope)+nanstd(slope)  
                    Res = Res_Orig*0.75;
                else
                    Res = Res_Orig;
                end
            end
            if IB == 1
                IBvals(i+1) = IBvals(i)+Res;
            else
                IBvals(i+1) = IBvals(i)-Res;
            end
        end
        
        i = i+1;
        if IBvals == 0
            break;
        end
        
    end
    IVmeasure.Tbath = SetupTES.SetPt.String;
    data(:,1) = IVmeasure.ibias;
    data(:,2) = IVmeasure.vout;
    
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
    
    file = strcat(Temp,'_Rf',num2str(SetupTES.Circuito.Rf.Value),'K_',dire,'_',pol,'_matlab.txt');
    save([handles.IVs_Dir file],'data','-ascii');
    
    % Importante que el TES_Circuit se haya actualizado con los valores de
    % Rf, mN, mS, Rpar, Rn
    
    TESDATA.circuit = TES_Circuit;
    TESDATA.circuit = TESDATA.circuit.Update(SetupTES.Circuit);
    IVCurveSet = TES_IVCurveSet;
    IVCurveSet = IVCurveSet.Update(IVmeasure);
    TESDATA.TES.n = [];
    if IB == 1
        IVsetP = IVCurveSet.GetIVTES(TESDATA);
    else
        IVsetN = IVCurveSet.GetIVTES(TESDATA);
    end
    
end          


function Medir_Zw_Noise(Temp,Opt,IZvalues,Path,Conf,SetupTES,handles)


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
    
    if Opt == 1 || Opt == 3 % Se mide el Zw
        
        if Conf.TF.Zw.DSA.On
            
            switch handles.DSA_TF_Zw_Menu.Value
                case 1 % Sweept sine
                    if handles.DSA_Input_Amp_Units.Value ~= 4
                        handles.DSA_Input_Amp_Units.Value = 2;  % mV
                        DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
                        Amp = str2double(handles.DSA_Input_Amp.String);
                    else
                        Amp = IZvalue(i)*1e1*str2double(handles.DSA_Input_Amp.String);
                    end
                    SetupTES.DSA = SetupTES.DSA.SineSweeptMode(Amp);
                case 2 % Fixed sine
                    handles.DSA_Input_Freq_Units.Value = 1;  % Hz
                    DSA_Input_Freq_Callback(handles.DSA_Input_Freq,[],handles);
                    Freq = str2double(handles.DSA_Input_Freq.String);
                    if handles.DSA_Input_Amp_Units.Value ~= 4
                        handles.DSA_Input_Amp_Units.Value = 2;  % mV
                        DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
                        Amp = str2double(handles.DSA_Input_Amp.String);
                    else
                        Amp = IZvalue(i)*1e1*str2double(handles.DSA_Input_Amp.String);
                    end
                    SetupTES.DSA = SetupTES.DSA.FixedSine(Amp,Freq);
                case 3 % White noise
                    if handles.DSA_Input_Amp_Units.Value ~= 4
                        handles.DSA_Input_Amp_Units.Value = 2;  % mV
                        DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
                        Amp = str2double(handles.DSA_Input_Amp.String);
                    else
                        Amp = IZvalue(i)*1e1*str2double(handles.DSA_Input_Amp.String);
                    end
                    SetupTES.DSA = SetupTES.DSA.WhiteNoise(Amp);
            end
            
            [SetupTES.DSA, datos] = SetupTES.DSA.Read;
            
            % Guardamos los datos en un fichero
            file = strcat('TF_',Itxt,'uA','.txt');
            save([Path file],'datos','-ascii');%salva los datos a fichero.
        end
        if Conf.TF.Zw.PXI.On
            
            SetupTES.PXI.AbortAcquisition;
            SetupTES.PXI = SetupTES.PXI.TF_Configuration;
            
            if handles.PXI_Input_Amp_Units == 4 % Porcentaje de Ibias
                Ireal = SetupTES.Squid.Read_Current_Value; % Devuelve el valor siempre en uA
                excitacion = Ireal.Value*1e1*str2double(handles.PXI_Input_Amp.String);
            else
                handles.PXI_Input_Amp_Units.Value = 2;
                excitacion = str2double(handles.PXI_Input_Amp.String);
            end
            
            SetupTES.DSA.SourceOn;
            SetupTES.DSA.WhiteNoise(excitacion);
            
            [data, ~] = SetupTES.PXI.Get_Wave_Form;
            
            sk = skewness(data);
            while abs(sk(3)) > SetupTES.PXI.Options.Skewness
                [data,~] = SetupTES.PXI.Get_Wave_Form;
                sk = skewness(data);
            end
            [txy,~] = tfestimate(data(:,2),data(:,3),[],[],2^14,SetupTES.PXI.ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
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
    
    if Opt == 2 || Opt == 3 % Se mide el Ruido
        if Conf.TF.Noise.DSA.On
            
            SetupTES.DSA = SetupTES.DSA.NoiseMode;
            [SetupTES.DSA, datos] = SetupTES.DSA.Read;
            
            % Guardamos los datos en un fichero
            file = strcat('HP_noise_',Itxt,'uA','.txt');
            save([Path file],'datos','-ascii');%salva los datos a fichero.
        end
        if Conf.TF.Noise.PXI.On
            
            SetupTES.PXI.AbortAcquisition;
            SetupTES.PXI = SetupTES.PXI.Noise_Configuration;
            
            [data, WfmI] = SetupTES.PXI.Get_Wave_Form;
            [psd,freq] = PSD(data);
            clear datos;
            datos(:,1) = freq;
            datos(:,2) = sqrt(psd);
            n_avg = SetupTES.PXI.Options.NAvg;
            for jj = 1:n_avg-1%%%Ya hemos adquirido una.
                [data, WfmI] = SetupTES.PXI.Get_Wave_Form;
                [psd,freq] = PSD(data);
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


function Medir_Pulsos(Temp,Conf,IZvalues,Path,SetupTES,handles)

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
    

