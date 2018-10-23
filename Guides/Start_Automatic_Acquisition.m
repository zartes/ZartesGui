function Start_Automatic_Acquisition(handles, SetupTES, Conf)


if Conf.OP2Field.On == 1                

    AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
    
    if ~ischar(AQ_dir)
        return;
    end
    Tstring = [num2str(Conf.Temp,' %3.1f') 'mK'];
           
    Campo_Dir = [AQ_dir filesep 'Campo' filesep Tstring filesep];
    if exist(Campo_Dir,'dir') == 0    
        succ = mkdir([AQ_dir filesep 'Campo' filesep], Tstring);
    end        
    
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
    
    button = questdlg('Do you want to store the results?','ZarTES v1.0','Yes','No','No');
    switch button
        case 'Yes'
            file = strcat('Field_',num2str(Ireal,'%4.3f'),'uA','.txt');
            save([Campo_Dir file],'data','-ascii'); %salva los datos a fichero.
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
        button = questdlg('temps.txt file already exitsDo you want to replace the temps.txt file?','ZarTES v1.0','Yes','No','No');
        switch button
            case 'Yes'
        end
    end
    fid = fopen([AQ_dir filesep 'tmp\temps.txt'],'a+');
    fprintf(fid,'%f \n',Conf.Temps.Values');
    fclose(fid);
    
    temps = Conf.Temps.Values*1e3;    
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
                    
                end
                pause(0.1);
            end
            if ishandle(h)
                delete(h)
                clear h1;
            end
        end
        %%
        
        if Conf.Field.Mode
            % (repeated for each B Field value)
            Ibvalues = Conf.Ibvalues.Values.p;
            succ = mkdir([AQ_dir filesep 'Campo' filesep], Tstring);
            Campo_Dir = [AQ_dir filesep 'Campo' filesep Tstring filesep];
            jj = 1;
            for j = 1:length(Bvalues)
                
                if Bvalues(j) ~= 0  % In the case of being just more than one single value and different than zero.
                    % Current Source for Field control must be activated
                    if j == 1
                        SetupTES.CurSource_Cal.Value = 1;
                        SetupTEScontrolers('CurSource_Cal_Callback',SetupTES.CurSource_Cal,[],guidata(SetupTES.CurSource_Cal))
                    end
                    SetupTES.CurSource_I_Units.Value = 1;
                    SetupTES.CurSource_I.String = num2str(Conf.Field.Values(j)*1e-6);  % Se pasan las corrientes en amperios
                    %                 SetupTES.CurSource_I_Units.Value = 1;
                    
                    SetupTES.CurSource_Set_I.Value = 1;
                    SetupTEScontrolers('CurSource_Set_I_Callback',SetupTES.CurSource_Set_I,[],guidata(SetupTES.CurSource_OnOff));
                    
                    SetupTES.CurSource_OnOff.Value = 1;
                    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
                    
                    
                    
                    
                    
                    SetupTES.SQ_Ibias.String = num2str(Ibvalues);
                    SetupTES.SQ_Ibias_Units.Value = 3;
                    SetupTES.SQ_Set_I.Value = 1;
                    SetupTEScontrolers('SQ_Set_I_Callback',SetupTES.SQ_Set_I,[],guidata(SetupTES.SQ_Set_I));
                    
                    averages = 1;
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
                    data(jj,2) = Bvalues(j); %*1e-6;
                    data(jj,3) = Ireal; %%%Vout
                    data(jj,4) = Vdc;
                    jj = jj+1;
                    SetupTES.CurSource_OnOff.Value = 0;
                    SetupTEScontrolers('CurSource_OnOff_Callback',SetupTES.CurSource_OnOff,[],guidata(SetupTES.CurSource_OnOff));
                    Ch = SetupTES.Result_Axes.Children;
                    plot(SetupTES.Result_Axes,data(:,2),data(:,4));
                    xlabel(SetupTES.Result_Axes,'Bfield (uA)')
                    ylabel(SetupTES.Result_Axes,'Vout (V)');
                    delete(Ch);
                end
                
                
            end
            button = questdlg('Do you want to store the results?','ZarTES v1.0','Yes','No','No');
            switch button
                case 'Yes'
                    file = strcat('Field_',num2str(Ireal,'%4.3f'),'uA','.txt');
                    save([Campo_Dir file],'data','-ascii'); %salva los datos a fichero.
            end
            return;
            
        end
        %% Acquisition block, once bath temperature and field were set
        
        if Conf.Ibvalues.Mode % If 1, then IV curves are acquired
            
            Ibvalues_Str = {'p';'n'};
            for k1 = 1:2  % Positive and negative Ibvalues
                Ibvalues = eval(['Conf.Ibvalues.Values.' Ibvalues_Str{k1} ';']);
                % Calibration
                SetupTEScontrolers('SQ_Calibration_Callback',SetupTES.SQ_Calibration,[],guidata(SetupTES.SQ_Calibration));
                Rf = str2double(SetupTES.SQ_Rf_real.String);
                handles.SetupTES.Circuit.Rf.Value = Rf;
                
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
                if temps(i) == 50 || temps(i) == 70
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
                end
                
            end % end For positive and negative
        end   % enf if IV Mode
        
        if Conf.Pulses.Mode % If 1, then Pulses are acquired
            
        end
        fid = fopen([SETstr(1:end-3) 'end'],'a+');
        fclose(fid);
        %     end
    end
    %%
    Conf.Ibvalues.Mode = handles.AQ_IVs.Value; % 0 (off), 1 (on)
    Conf.Ibvalues.Values = Ibvalues;
    
    Conf.Field.Mode = handles.BField_Mode.Value;  % 0 (off), 1 (on)
    Conf.Field.Values = Field;
    
    Conf.ZwNoise.Mode = handles.AQ_mode.Value; % 0 (off), 1 (on)
    Conf.ZwNoise.Zw.Parameters = [];
    Conf.ZwNoise.Noise.Parameters = [];
    
    Conf.Pulses.Mode = handles.AQ_Pulse.Value; % 0 (off), 1 (on)
    Conf.Pulses.Parameters = [];
    
end


