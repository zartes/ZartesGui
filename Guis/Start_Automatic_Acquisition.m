function Start_Automatic_Acquisition(handles, SetupTES, Conf)


if Conf.OP2Field.On ~= 0
    switch Conf.OP2Field.On
        case 1 % Field Sweeping
            
            AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
            
            if ~ischar(AQ_dir)
                return;
            end
            Tstring = [num2str(Conf.Temp,' %3.1f') 'mK'];
            
            Campo_Dir = [AQ_dir filesep 'Campo' filesep Tstring filesep];
            if exist(Campo_Dir,'dir') == 0
                succ = mkdir([AQ_dir filesep 'Campo' filesep], Tstring);
            end
            
            % Ponemos el Squid en Estado Normal
            SetupTES.SQ_TES2NormalState.Value = 1;
            SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(Conf.Ibias),guidata(SetupTES.SQ_TES2NormalState));
            % Reset Closed Loop
            SetupTES.SQ_Reset_Closed_Loop.Value = 1;
            SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
            
            % Adquirimos una Curva I-V para determinar la Ibias acorde con el Rn
            Ibvalues = 500:10:0;
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
                IVmeasure.ibias(i) = str2double(SetupTES.SQ_realIbias.String);
            end
            IVmeasure.Tbath = Nan;
            
            IVset = GetIVTES(IVmeasure,SetupTES.Circuit);
            Conf.Ibias = BuildIbiasFromRp(IVset,Conf.Rn);
            handles.Field_Ibias.String = num2str(Conf.Ibias);
            
            % Calibramos la fuente de corriente
            SetupTES.CurSource_Cal.Value = 1;
            SetupTEScontrolers('CurSource_Cal_Callback',SetupTES.CurSource_Cal,[],guidata(SetupTES.CurSource_Cal))
            
            % Ponemos el Squid en Estado Normal
            SetupTES.SQ_TES2NormalState.Value = 1;
            SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,sign(Conf.Ibias),guidata(SetupTES.SQ_TES2NormalState));
            % Reset Closed Loop
            SetupTES.SQ_Reset_Closed_Loop.Value = 1;
            SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
            
            % Ponemos el valor de Ibias en el Squid
            SetupTES.SQ_Ibias.String = num2str(Conf.Ibias);
            SetupTES.SQ_Ibias_Units.Value = 3;
            SetupTES.SQ_Set_I.Value = 1;
            SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
            
            % Leemos el valor real de Ibias en el Squid
            SetupTES.SQ_Read_I.Value = 1;
            SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
            Ireal = str2double(SetupTES.SQ_realIbias.String);
            
            for j = 1:length(Conf.Field)
                
                % Ponemos el valor de corriente en la fuente
                SetupTES.CurSource_I_Units.Value = 1;
                SetupTES.CurSource_I.String = num2str(Conf.Field(j)*1e-6);  % Se pasan las corrientes en amperios
                SetupTES.CurSource_Set_I.Value = 1;
                SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
                SetupTES.CurSource_OnOff.Value = 1;
                SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
                
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
                data(jj,2) = Conf.Field(j); %*1e-6;
                data(jj,3) = Ireal; %%%Vout
                data(jj,4) = Vdc;
                jj = jj+1;
                
                % Desactivamos la salida de corriente de la fuente
                SetupTES.CurSource_OnOff.Value = 0;
                SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
                
                % Actualizamos el gráfico
                Ch = SetupTES.Result_Axes.Children;
                plot(SetupTES.Result_Axes,data(:,2),data(:,4));
                xlabel(SetupTES.Result_Axes,'Bfield (uA)')
                ylabel(SetupTES.Result_Axes,'Vout (V)');
                set(handles.Result_Axes,'fontsize',12);
                delete(Ch);
            end
            [val, ind] = max(data(:,4));
            plot(SetupTES.Result_Axes,data(ind,2),val,'*','Color','g','MarkerSize',10);
            button = questdlg('Is the green asterisk where the Field produces the maximum Vout?','ZarTES v1.0','Yes','No','No');
            switch button
                case 'Yes'
                    file = strcat('Field_',num2str(Ireal,'%4.3f'),'uA','.txt');
                    save([Campo_Dir file],'data','-ascii'); %salva los datos a fichero.
                case 'No'
                    warndlg('Please, select another point in the graph','ZarTES v1.0');
                    [X,~] = ginput(1);
                    ind_field = find(data(ind,2) > X,1); %#ok<NASGU>
                    msgbox(['Bfield: ' num2str(data(ind,2)) ' uA is selected as remanent field'],'ZarTES v1.0');
            end
            RemanentField = data(ind,2);
            handles.AQ_Field.String = num2str(RemanentField);
            
            button = questdlg('Do you want to store the results?','ZarTES v1.0','Yes','No','No');
            switch button
                case 'Yes'
                    file = strcat('Field_',num2str(Ireal,'%4.3f'),'uA','.txt');
                    save([Campo_Dir file],'data','-ascii'); %salva los datos a fichero.
            end
            
        case 2 % Critical Intensities
            AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');            
            if ~ischar(AQ_dir)
                return;
            end            
           
            Campo_Dir = [AQ_dir filesep 'ICs' filesep];
            if exist(Campo_Dir,'dir') == 0
                succ = mkdir([AQ_dir filesep 'ICs' filesep]);
            end
            if exist([Campo_Dir filesep 'tmp'],'dir') == 0
                succ = mkdir([Campo_Dir filesep 'tmp']);
            end
            
            
                       
            BfieldValues = Conf.Field;    
            StrCond = {'p';'n'};            
            Ibvalues_p = sort(Conf.Ibvalues.Values.p,'ascend');
            Ibvalues_n = sort(Conf.Ibvalues.Values.n,'descend');
            Temps = Conf.Temp;
            
            fid = fopen([Campo_Dir filesep 'tmp\temps.txt'],'a+');
            fprintf(fid,'%f \n',Temps'*1e-3);
            fclose(fid);
            
            TempDir = [Campo_Dir filesep 'tmp\'];
            
            % En este punto debemos de incorporar al control de temperatura
            % el archivo temps que hemos generado.
            
            waitfor(warndlg(['Open Labview KEIVFRONTPANEL and select temps file in ' TempDir '. Once done, close this window to continue, NOT BEFORE!'],'ZarTES v1.0'));
                        
            % Para cada Temperatura se toman curvas I-V a cada valor de
            % Campo
            for i = 1:length(Temps)
                % El sistema tiene que llegar a la temperatura deseada
                Tstring = sprintf('%0.1fmK',Temps(i));
                SETstr = [TempDir 'T' Tstring '.stb'];                
                if length(Temps) > 1
                    %% Waiting for Tbath set file
                    h = waitbar(0,['Please wait... Acquisition will start when Tbath ' Tstring]);
                    h1.hi = 0;
                    h1.Nsteps = 50;                    
                    while(~exist(SETstr,'file'))
                        if ishandle(h)
                            waitbar(h1.hi/h1.Nsteps,h)
                            h1.hi = h1.hi+1;
                            if h1.hi > h1.Nsteps
                                h1.hi = 0;
                            end
                            
                        end
                        pause(0.1);
                    end
                    if ishandle(h)
                        delete(h)
                        clear h1;
                    end
                end
                for j = 1:length(BfieldValues)
                    
                    % Ponemos el valor de corriente en la fuente
                    SetupTES.CurSource_I_Units.Value = 1;
                    SetupTES.CurSource_I.String = num2str(BfieldValues(j)*1e-6);  % Se pasan las corrientes en amperios
                    SetupTES.CurSource_Set_I.Value = 1;
                    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
                    SetupTES.CurSource_OnOff.Value = 1;
                    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
                    
                    % Reset Closed Loop
                    SetupTES.SQ_Reset_Closed_Loop.Value = 1;
                    SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
                    
                    % Adquirimos Curvas I-V para determinar el Ibias crítica en el que pasa de superconductor a estado normal                   
                    for cond = 1:2
                        for k = 1:length(eval(['Ibvalues_' StrCond{cond}]))
                            SetupTES.SQ_Ibias.String = num2str(eval(['Ibvalues_' StrCond{cond} '(k)']));
                            SetupTES.SQ_Ibias_Units.Value = 3;
                            SetupTES.SQ_Set_I.Value = 1;
                            SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
                            
                            averages = 1;
                            for i_av = 1:averages
                                SetupTES.Multi_Read.Value = 1;
                                SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
                                aux1{i_av} = str2double(SetupTES.Multi_Value.String);
                                if i_av == averages
                                    IVmeasure.vout(k) = mean(cell2mat(aux1));
                                end
                            end
                            % Read I real value
                            SetupTES.SQ_Read_I.Value = 1;
                            SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
                            IVmeasure.ibias(k) = str2double(SetupTES.SQ_realIbias.String);
                            if k > 1
                                if IVmeasure.vout(k) < IVmeasure.vout(k-1)                                    
                                    eval(['ICpairs(j).' StrCond{cond} ' = IVmeasure.ibias(k-1);'])
                                    break;
                                end
                            end
                        end
                    end % End Ibvalues
                    ICpairs(j).B = BfieldValues(j);
                end % End Bfield values
                
                % The file Temp.end is created to go on with the next bath
                % temperature
                DONEstr = [TempDir 'T' Tstring '.end'];                                
                f = fopen(DONEstr, 'w');
                if f < 0
                    disp(errmsg);
                    return
                end
                fclose(f);
                
                FileStr = ['ICpairs' Tstring 'mK.mat'];
                save([AQ_dir FileStr],'ICpairs');
                
                clear ICpairs IVmeasure
            end  % End Temps
            
    end
    
else    
    AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
    
    if ~ischar(AQ_dir)
        return;
    end
    
    if exist([AQ_dir filesep 'tmp'],'dir') == 0    
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(AQ_dir,'tmp'); %#ok<ASGLU>
        if ~SUCCESS
            warndlg(MESSAGE,'ZarTES v1.0');
            msgbox('Acquisition Aborted','ZarTES v1.0');
        end
    end
    if exist([AQ_dir filesep 'IVs'],'dir') == 0
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(AQ_dir,'IVs'); %#ok<ASGLU>
        if ~SUCCESS
            warndlg(MESSAGE,'ZarTES v1.0');
            msgbox('Acquisition Aborted','ZarTES v1.0');
        end
    end
    if exist([AQ_dir filesep 'Z(w)-Ruido'],'dir') == 0
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(AQ_dir,'Z(w)-Ruido'); %#ok<ASGLU>
        if ~SUCCESS
            warndlg(MESSAGE,'ZarTES v1.0');
            msgbox('Acquisition Aborted','ZarTES v1.0');
        end
    end
    
    % handles perteneciente a los setups
    % Conf estructura de configuración de la adquisición automática
    
    % Now temps array is in milliKelvin
    
    if exist([AQ_dir filesep 'tmp\temps.txt'],'file')
        button = questdlg('temps.txt file already exits. Do you want to replace the temps.txt file?','ZarTES v1.0','Yes','No','No');
        switch button
            case 'Yes'
                delete([AQ_dir filesep 'tmp\temps.txt']);
        end
    end
    fid = fopen([AQ_dir filesep 'tmp\temps.txt'],'a+');
    fprintf(fid,'%f \n',Conf.Temps.Values*1e-3');
    fclose(fid);
    
    temps = Conf.Temps.Values;    
    TempDir = [AQ_dir filesep 'tmp\'];    
    Bvalues = Conf.Field.Values;
    
    %% Main block (repeated for each temperature value)
    
    % - Intensity-Voltage acquisition block
    % - Critical intensities acquisition block (Optional)
    % - Acquisition block varying magnetic field values
    % - Impedance + noise (Z(w)+ N) acquisition block
    %   - Acquire or not an IV coarse (Optional)
    for i = 1:length(temps)
        
        % Generating a temporal file to (specify what for)
        Tstring = sprintf('%0.1fmK',temps(i));
        SETstr = [TempDir 'T' Tstring '.stb'];
        
        if length(temps) > 1
            %% Waiting for Tbath set file
            h = waitbar(0,['Please wait... Acquisition will start at Tbath ' Tstring]);
            h1.hi = 0;
            h1.Nsteps = 50;            
            while(~exist(SETstr,'file'))
                if ishandle(h)
                    waitbar(h1.hi/h1.Nsteps,h)
                    h1.hi = h1.hi+1;
                    if h1.hi > h1.Nsteps
                        h1.hi = 0;
                    end                    
                else
                    return;
                end
                pause(0.1);
            end
            if ishandle(h)
                delete(h)
                clear h1;
            end
        end
        %%
        %% Acquisition block, once bath temperature and field were set
        % Calibration
        SetupTEScontrolers('SQ_Calibration_Callback',SetupTES.SQ_Calibration,[],guidata(SetupTES.SQ_Calibration));
        Rf = str2double(SetupTES.SQ_Rf_real.String);
        handles.SetupTES.Circuit.Rf.Value = Rf;
        SetupTES.CurSource_Cal.Value = 1;
        SetupTEScontrolers('CurSource_Cal_Callback',SetupTES.CurSource_Cal,[],guidata(SetupTES.CurSource_Cal))
        
        SetupTES.CurSource_I_Units.Value = 1;
        SetupTES.CurSource_I.String = num2str(Bvalues*1e-6);  % Se pasan las corrientes en amperios
        SetupTES.CurSource_Set_I.Value = 1;
        SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
        
        SetupTES.CurSource_OnOff.Value = 1;
        SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
        
        if Conf.Ibvalues.Mode % If 1, then IV curves are acquired
            
            Ibvalues_Str = {'p';'n'};
            for k1 = 1:2  % Positive and negative Ibvalues
                if k1 == 1
                    Ibvalues = sort(eval(['Conf.Ibvalues.Values.' Ibvalues_Str{k1} ';']),'descend');                
                else
                    Ibvalues = sort(eval(['Conf.Ibvalues.Values.' Ibvalues_Str{k1} ';']),'ascend');  
                end
                
                % Configuration to be stored
                [signo,pol,dire] = IbvaluesExtraction(Ibvalues);
                
                % Set TES to Normal State
                SetupTES.SQ_TES2NormalState.Value = 1;
                SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,signo,guidata(SetupTES.SQ_TES2NormalState));
                
                % Reset Closed Loop
                SetupTES.SQ_Reset_Closed_Loop.Value = 1;
                SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
                
                data = [];
                slope = 0;
                state = 0;
                averages = 1;
                jj = 1;
                for k = 1:length(Ibvalues)  % (Repeated for each Ibvalue)
                    
                    %% Adapting Ibvalues resolution (under construction)
                    disp(['Ibias: ' num2str(Ibvalues(k)) ' uA'])
                    if slope > 3000  % State variable changes from 0 (normal) to 1 (superconductor)
                        state = 1;
                    end %%% state = 1 -> superconductor. Be aware! slope value of 3000 is just for Rf = 3Kohm.
                    
                    if state && mod(Ibvalues(k),5) %%% When the state is superconductor then the resolution is changed
                        continue;
                    end
                    
                    % Set Ibvalue
                    SetupTES.SQ_Ibias.String = num2str(Ibvalues(k));
                    SetupTES.SQ_Ibias_Units.Value = 3;
                    SetupTES.SQ_Set_I.Value = 1;
                    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
                    if k == 1
                        pause(2);
                    end
                    for i_av = 1:averages
                        SetupTES.Multi_Read.Value = 1;
                        SetupTEScontrolers('Multi_Read_Callback',SetupTES.Multi_Read,[],guidata(SetupTES.Multi_Read));
                        aux1{i_av} = str2double(SetupTES.Multi_Value.String);
                        if i_av == averages
                            Vdc = mean(cell2mat(aux1));
                        end
                    end
                    
                    % Read I real value
                    SetupTES.SQ_Read_I.Value = 1;
                    SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
                    Ireal = str2double(SetupTES.SQ_realIbias.String);
                    
                    data(jj,1) = now;
                    data(jj,2) = Ireal; %*1e-6;
                    data(jj,3) = 0; %%%Vout
                    data(jj,4) = Vdc;
                    jj = jj+1;
                    
                    if k > 1 && ~state
                        slope = (data(k,4)-data(k-1,4))/((data(k,2)-data(k-1,2))*1e-6);
                    end
                end
                IV = corregir1rama(data);
                IV.Tbath = temps(i);
                
                file = strcat(num2str(temps(i),' %3.1f'),'mK_Rf',num2str(Rf/1000),'K_',dire,'_',pol,'_matlab.txt');
                save([AQ_dir filesep 'IVs' filesep file],'data','-ascii');
                
                %%%%%%%%%%%%%%%%%%%%%%%%% Impedancia compleja
                
                if Conf.ZwNoise.Mode % If 1, then Z(w) + Noise are acquired
                    if k1 == 2
                        succ = mkdir([AQ_dir filesep 'Z(w)-Ruido' filesep 'Negative Bias' filesep], Tstring);
                        ZwNoise_Dir = [AQ_dir filesep 'Z(w)-Ruido' filesep 'Negative Bias' filesep Tstring filesep];
                    else
                        succ = mkdir([AQ_dir filesep 'Z(w)-Ruido' filesep], Tstring);
                        ZwNoise_Dir = [AQ_dir filesep 'Z(w)-Ruido' filesep Tstring filesep];
                    end
                    
                    if succ == 0
                        disp(['Error creating the ' Tstring ' folder!']);
                        QuestButton = questdlg('Do you want to continue?', ...
                            'Warning', ...
                            'Yes', 'No', 'No');
                        switch QuestButton
                            case 'No'
                                return;
                            case 'Yes'
                            otherwise
                                return;
                        end
                    end
                    
                    
                    IVset = GetIVTES(handles.SetupTES.Circuit,IV);
                    rpp = (0.95:-0.05:0.01); %%%Vector con los puntos donde tomar Z(w).
                    if temps(i) == 0.050 || temps(i) == 0.07
                        rpp = [0.9:-0.05:0.2 0.19:-0.01:0.1];
                    end
                    rpn = (0.90:-0.1:0.1);
                    
                    if k1 == 1
                        IZvalues = BuildIbiasFromRp(IVset,rpp);
                    else
                        IZvalues = BuildIbiasFromRp(IVset,rpn);
                    end
                    
                    
                    % Set TES to Normal State
                    SetupTES.SQ_TES2NormalState.Value = 1;
                    SetupTEScontrolers('SQ_TES2NormalState_Callback',SetupTES.SQ_TES2NormalState,signo,guidata(SetupTES.SQ_TES2NormalState));
                    
                    for iz = 1:length(IZvalues)
                        
                        % Reset Closed Loop
                        SetupTES.SQ_Reset_Closed_Loop.Value = 1;
                        SetupTEScontrolers('SQ_Reset_Closed_Loop_Callback',SetupTES.SQ_Reset_Closed_Loop,[],guidata(SetupTES.SQ_Reset_Closed_Loop));
                        
                        % Set Ibvalue
                        SetupTES.SQ_Ibias.String = num2str(IZvalues(iz));
                        SetupTES.SQ_Ibias_Units.Value = 3;
                        SetupTES.SQ_Set_I.Value = 1;
                        SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
                        
                        % Read I real value
                        SetupTES.SQ_Read_I.Value = 1;
                        SetupTEScontrolers('SQ_Read_I_Callback',SetupTES.SQ_Read_I,[],guidata(SetupTES.SQ_Read_I));
                        Itxt = str2double(SetupTES.SQ_realIbias.String);
                        
                        %%% Esta parte hay que protegerla de que no
                        %%% funcione correctamente la conexion
                        %
                        if handles.AQ_DSA.Value
                            SetupTES.DSA_On.Value = 1;
                        end
                        if handles.AQ_PXI.Value
                            SetupTES.PXI_On.Value = 1;
                        end
                        
                        % Medir TF
                        SetupTES.TF_Mode.Value = 1;
                        SetupTES.Noise_Mode.Value = 0;
                        SetupTES.DSA_OnOff.Value = 1;
                        SetupTEScontrolers('DSA_OnOff_Callback',SetupTES.DSA_OnOff, [], guidata(SetupTES.DSA_OnOff));
                        SetupTES.DSA.SineSweeptMode(IZvalues(iz)*1e-6*0.02);
                        SetupTES.DSA_Read.Value = 1;
                        SetupTEScontrolers('DSA_Read_Callback',SetupTES.DSA_Read, 1, guidata(SetupTES.DSA_Read));
                        
                        
                        % Medir Ruido
                        SetupTES.TF_Mode.Value = 0;
                        SetupTES.Noise_Mode.Value = 1;
                        SetupTES.DSA_OnOff.Value = 1;
                        SetupTEScontrolers('DSA_OnOff_Callback',SetupTES.DSA_OnOff, [], guidata(SetupTES.DSA_OnOff));
                        SetupTES.DSA_Read.Value = 1;
                        SetupTEScontrolers('DSA_Read_Callback',SetupTES.DSA_Read, 1, guidata(SetupTES.DSA_Read));
                        
                        SetupTES = guidata(SetupTES.SetupTES);
                        %%%%%%%%%%%%%% Complex impedance Z(w) acquisition
                        %%%%%%%%%%%%%% by DSA analyzer
                        try
                            if handles.AQ_DSA.Value
                                file = strcat('TF_',num2str(Itxt,'%4.3f'),'uA','.txt');
                                data = SetupTES.DSA_TF_Data;
                                save([ZwNoise_Dir file],'data','-ascii');%salva los datos a fichero.
                                
                                clear data;
                                data = SetupTES.DSA_Noise_Data;
                                file = strcat('HP_noise_',num2str(Itxt,'%4.3f'),'uA','.txt');
                                save([ZwNoise_Dir file],'data','-ascii'); %salva los datos a fichero.
                            end
                            if handles.AQ_PXI.Value
                                clear data;
                                data = SetupTES.PXI_TF_Data;
                                file = strcat('PXI_TF_',num2str(Itxt,'%4.3f'),'uA','.txt');
                                save([ZwNoise_Dir file],'data','-ascii'); %salva los datos a fichero.
                                
                                clear data;
                                data = SetupTES.PXI_NoiseData;
                                file = strcat('PXI_noise_',num2str(Itxt,'%4.3f'),'uA','.txt');
                                save([ZwNoise_Dir file],'data','-ascii'); %salva los datos a fichero.
                            end
                            
                        catch
                            %% Añadir una parte que haga referencia a que estos datos no se han adquirido
                        end
                        
                    end  % end for IZ_values
                    
                end % end if ZwNoiseMode
                if Conf.Pulses.Mode % If 1, then Pulses are acquired
                    SetupTEScontrolers('PXI_Pulses_Read_Callback',SetupTES.PXI_Pulses_Read, [], guidata(SetupTES.PXI_Pulses_Read));
                end
                
            end % end For positive and negative
        end   % enf if IV Mode        
        
        fid = fopen([SETstr(1:end-3) 'end'],'a+');
        fclose(fid);
        %     end
    end
    %%
%     Conf.Ibvalues.Mode = handles.AQ_IVs.Value; % 0 (off), 1 (on)
%     Conf.Ibvalues.Values = Conf.Ibvalues.Values;
%     
%     Conf.Field.Mode = handles.BField_Mode.Value;  % 0 (off), 1 (on)
%     Conf.Field.Values = Bvalues;
%     
%     Conf.ZwNoise.Mode = handles.AQ_Zw.Value; % 0 (off), 1 (on)
%     Conf.ZwNoise.Zw.Parameters = [];
%     Conf.ZwNoise.Noise.Parameters = [];
%     
%     Conf.Pulses.Mode = handles.AQ_Pulse.Value; % 0 (off), 1 (on)
%     Conf.Pulses.Parameters = [];
    
end


