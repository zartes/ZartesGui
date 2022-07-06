function [R, T, Rsig, Tsig, Pt, Dt] = MedidaRTs(avs_Device,handles,TipoCurva,TempRange,TempStep,ToleranceError,axes)
% Funcion que realiza las medidas con el instrumento AVS y la aplicación de Labview
% IGHFrontPanel.vi
%
% Inputs:
% - avs_Device: object related to AVS47 device
% - vi: ActxServer related to LabView software for Mixing Chamber control
% - TipoCurva: temperature variation: 'Ascendente' or 'Descendente'
% - TempRange: vector of two elements containing two temperature values [T1 T2]
% - TempStep: step of temperature variations when M/C Temp is reached the
%             tolerance error
% - ToleranceError: Tolerance of relative error respect M/C temp and T set. 
% - axes: handles to figure axes
%
% Outputs:
% - R: object related to AVS47 device
% - T: ActxServer related to LabView software for Mixing Chamber control
%
% Ejemplo de uso
% [R, T] = MedidaRTs(avs_Device,vi,'Descendente',[0.085 0.064],0.001,0.2);
%
% Last Update 22/01/2019


if nargin < 2
    return;
end
if nargin == 2
    TipoCurva = 'Descendente';
    TempRange = [0.085 0.060];  % mK
    TempStep = 0.005;  % K
    ToleranceError = 2; % Relative Error x 100
end

R = [];
T = [];
Rsig = [];
Tsig = [];
Pt = [];
Dt = [];
stop_value = 0;


T_MC = str2double(get(handles.MCTemp,'String'));

switch TipoCurva
    case 'Ascendente'
        SetPt = min(TempRange);
        TempFin = max(TempRange);
    case 'Descendente'
        SetPt = max(TempRange);
        TempFin = min(TempRange);
end


% Fija la temperatura de referencia
%% Oxford
% vi.vi_IGHFrontPanel.FPState = 4;
% pause(0.1)
% vi.vi_IGHFrontPanel.FPState = 1;
% pause(0.1)
% vi.vi_IGHFrontPanel.SetControlValue('Settings',1);
% pause(1.5)
% vi.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
% pause(0.1)
% while strcmp(vi.vi_PromptForT.FPState,'eClosed')
%     pause(0.1);
% end
% vi.vi_PromptForT.SetControlValue('Set T',SetPt)%
% pause(0.4)
% vi.vi_PromptForT.SetControlValue('Set T',SetPt)%
% pause(0.1)
% vi.vi_PromptForT.SetControlValue('OK',1)
% pause(0.1)
% while strcmp(vi.vi_PromptForT.FPState,'eClosed')
%     pause(0.1);
% end
%% Bluefors
handles.BF.SetTemp(SetPt);

CurrentStepPower = str2double(get(handles.PowerStep,'String'))*1e-6;

a = load('RefValues.mat');
BasalPower = spline(a.RefTemps,a.RefPowers*1e-6,SetPt);  % Actualizar con los datos de caracterizacion.

Error = (abs(T_MC-SetPt)/SetPt)*100;
% disp(Error);
divnum = [0 3 10 30 100 300 1000 3000]; % uA
handles.div = divnum(get(handles.Exc_List,'Value'));

h = axes;
xlabel(h,'T (K)')
ylabel(h,'R (Ohm)');
hold(h,'on');
avs_Device.Read;
% clear R T;
P = handles.BF.P;
I = handles.BF.I;
D = handles.BF.D;
MaxPower = handles.BF.ReadMaxPower;



% if ~handles.TemperatureControl.Value  % Control de la potencia con control PID por el BlueFors (No recomendado)
%     jj = 1;
%     %%  Situar el BlueFors en PID control
%     handles.BF.SetPID(P,I,D);
%     PID_mode = handles.BF.ReadPIDStatus;
%     if ~PID_mode
%         handles.BF.SetTempControl(1); %Manual
%     end
%         
%     while abs(SetPt-TempFin) > 0.0001        
%         
%         hnd = guidata(axes);
%         hnd.MCTemp.String = num2str(T_MC);
%         hnd.TsetCurrent.String = num2str(SetPt);
%         stop_value = hnd.Stop.UserData;
%         
%         if ~stop_value
%             [avs_Device, R(jj)] = avs_Device.Read;
%             while isempty(R(jj).Value)
%                 [avs_Device, R(jj)] = avs_Device.Read;
%             end
%             
%             T_MC = str2double(get(handles.MCTemp,'String'));
%             
%             
%             Error = (abs(T_MC-SetPt)/SetPt)*100;
%             disp(Error);
%             T(jj) = T_MC;
%             he = findobj('Type','Line','DisplayName','Current');
%             delete(he);
%             plot(h,T(1:jj),[R(1:jj).Value],'r*','DisplayName','Current')
%             if Error < ToleranceError
%                 
%                 % Bluefors
%                 % Añadir el cambio de temperatura o cambio de potencia.
% %                 if handles.TemperatureControl.Value    % Control de la potencia mediante pasos en la temperatura de referencia
%                     switch TipoCurva
%                         case 'Ascendente'
%                             SetPt = min(SetPt+TempStep,TempFin);
%                         case 'Descendente'
%                             SetPt = max(SetPt-TempStep,TempFin);
%                     end
%                     handles.BF.SetTemp(SetPt);
%                     
%                     hnd.TsetCurrent.String = num2str(SetPt);
%                 
%             end
%             jj = jj +1;
%         else
%             hnd.Stop.UserData = 0;
%             guidata(hnd.Stop,guidata(axes))
%             R = [R.Value];
%             return;
%         end
%     end
%     
%     R = [R.Value];
%     
%     
%     
%     
% else
if handles.TemperatureControl.Value % Control de la potencia con control PID de forma manual
    hnd = guidata(axes);
    hnd.MCTemp.String = num2str(T_MC);
    
    hnd.TsetCurrent.String = num2str(SetPt);
    TempRange = [str2double(get(hnd.Temp1,'String')) str2double(get(hnd.Temp2,'String'))];
    TipoCurva_1 = {'Ascendente';'Descendente'};
    Curva = TipoCurva_1{get(handles.Scan_Type,'Value')};
    switch Curva
        case 'Ascendente'
            TempFin = max(TempRange);
            CondStop = 'T_MC-TempFin < 0';
        case 'Descendente'
            TempFin = min(TempRange);
            CondStop = 'T_MC-TempFin > 0';
    end
    
    % Pasar a modo manual del BlueFors
    PID_mode = handles.BF.ReadPIDStatus;
    if PID_mode
        handles.BF.SetTempControl(0); %Manual
    end
    pause(0.2);
%     stop_value = hnd.Stop.UserData;
    StopVal = stop_meas(hnd);
    Error = zeros(2,1);
    % La potencia de inicio se actualiza con la que tiene el heater al
    % comienzo
    Power = handles.BF.ReadPower;
    sumError = Power*handles.BF.I/handles.BF.P;
    
    jj = 1;
    t = tic;
    while eval(CondStop)
        hnd = guidata(axes);
        hnd.MCTemp.String = num2str(T_MC);
        %         CurrentStepPower = str2double(hnd.PowerStep.String)*1e-3;
        TempStep = str2double(hnd.Temp_Step.String);
%         stop_value = hnd.Stop.UserData;
        hnd.TsetCurrent.String = num2str(SetPt);
        
        TempRange = [str2double(get(hnd.Temp1,'String')) str2double(get(hnd.Temp2,'String'))];
        TipoCurva_1 = {'Ascendente';'Descendente'};
        Curva = TipoCurva_1{get(handles.Scan_Type,'Value')};
        switch Curva
            case 'Ascendente'                
                TempFin = max(TempRange);
                CondStop = 'T_MC-TempFin < 0';
            case 'Descendente'                
                TempFin = min(TempRange);
                CondStop = 'T_MC-TempFin > 0';
        end
        
        %     R.Value = [];
        % Contador de ciclos de lectura de T_MC
        Nciclos = str2double(get(handles.Nciclos,'String'));
        k = 1;
        k1 = 1;
        Rp = [];
        T_MC = [];
        while k < Nciclos+1
            hnd = guidata(axes);
            if ~StopVal
                % Lectura del AVS
                [avs_Device, R_1] = avs_Device.Read;
                %                         t = toc;
                %                         disp(t)
                while isempty(R_1.Value) % Protección ante lecturas vacias
                    [avs_Device, R_1] = avs_Device.Read;
                end
                
                % Mira si el ByPass está activado
                if handles.ActivateAVSByPass.Value
                    R_1.Value = R_1.Value*handles.div/str2double(get(handles.CurrentByPass,'String'));
                end
                Rp(k1) = R_1.Value;
                % Se comprueba la temperatura de la mixing
                T_MC(k1) = str2double(get(handles.MCTemp,'String'));
                while isnan(T_MC(k1))
                    T_MC(k1) = str2double(get(handles.MCTemp,'String'));
                end
                k1 = k1 + 1;
                StopVal = stop_meas(hnd);
                if StopVal == 1
                    break;
                end
                
            end
            if StopVal == 1
                break;
            end
            k = k + 1;
        end
        R(jj) = nanmean(Rp);
        Rsig(jj) = nanstd(Rp);
        T(jj) = nanmean(T_MC);
        Tsig(jj) = nanstd(T_MC);
        
        dt = 5;
        hnd.E(1) = hnd.SetPt-T_MC;
        hnd.U(1) = max(0,hnd.U(2) + ...
            hnd.BF.P*(hnd.E(1)-hnd.E(2)) + ...
            (hnd.BF.P/hnd.BF.I)*hnd.E(1)*dt);
        
        hnd.E(3) = hnd.E(2);
        hnd.E(2) = hnd.E(1);
        hnd.U(2) = hnd.U(1);
        
        Pt(jj) = hnd.U(1);
        Dt(jj) = dt;
        
%         % calculo de la potencia a suministrar
%         Error = [SetPt-T(jj); Error(1:end-1)];
%         sumError = sumError + Error(1);
%         SetPower = min(max(handles.BF.P*(Error(1) + (1/handles.BF.I)*sumError + handles.BF.D*diff(Error([2 1]))),0),MaxPower);
        
%         handles.BF.P
        
        
        he = findobj('Type','Line','DisplayName','Current');
        delete(he);
        plot(h,T(1:jj),[R(1:jj)],'-ro','DisplayName','Current')
        
        SetPower = Pt(jj);
        handles.BF.SetPower(SetPower);
        %             disp(SetPower)
        if (abs(T_MC-SetPt)/SetPt)*100 < ToleranceError %(abs(T_MC-SetPt) < 0.1
            switch TipoCurva
                case 'Ascendente'
                    SetPt = min(SetPt+TempStep,TempFin);
                    handles.BF.SetTemp(SetPt);
                    
                case 'Descendente'
                    SetPt = max(SetPt-TempStep,TempFin);
                    handles.BF.SetTemp(SetPt);
            end
        end
        
        
        hnd.TsetCurrent.String = num2str(SetPt);
        jj = jj +1;
        guidata(axes,hnd)
        
        %         else
        %             hnd.Stop.UserData = 0;
        %             guidata(hnd.Stop,guidata(axes))
        %             R = [R.Value];
        %             return;
    end
    
    
    %     R = [R.Value];
    
elseif handles.PowerControl.Value
    
    hnd = guidata(axes);
    hnd.SetPower = handles.SetPower;
    if ~hnd.autopower.Value
        stop(hnd.AutoPwr);
    end
    hnd.MCTemp.String = num2str(T_MC);
    
    hnd.TsetCurrent.String = num2str(SetPt);
    switch TipoCurva
        case 'Ascendente'
            CondStop = 'T_MC-TempFin < 0';
            
        case 'Descendente'
            CondStop = 'T_MC-TempFin > 0';
    end
    
    % Pasar a modo manual del BlueFors
    PID_mode = handles.BF.ReadPIDStatus;
    if PID_mode
        handles.BF.SetTempControl(0); %Manual
    end

    jj = 1;
    t = tic;
    while eval(CondStop)   % Mientras no se cumpla la condición de parada
        
        SetPower = hnd.SetPower;        
        hnd = guidata(axes);
        TempRange = [str2double(get(hnd.Temp1,'String')) str2double(get(hnd.Temp2,'String'))];
        TipoCurva_1 = {'Ascendente';'Descendente'};
        Curva = TipoCurva_1{get(handles.Scan_Type,'Value')};
        switch Curva
            case 'Ascendente'                
                TempFin = max(TempRange);
                CondStop = 'T_MC-TempFin < 0';
            case 'Descendente'                
                TempFin = min(TempRange);
                CondStop = 'T_MC-TempFin > 0';
        end
        if ~hnd.autopower.Value
            stop(hnd.AutoPwr);
        elseif strcmp(hnd.AutoPwr.Running,'off') 
            start(hnd.AutoPwr);
        end
        hnd.MCTemp.String = num2str(T_MC); % La T_MC se actualiza con un timer cada 5 segundos
%         CurrentStepPower = str2double(hnd.PowerStep.String)*1e-3;
%         TempStep = str2double(hnd.Temp_Step.String);
        stop_value = hnd.Stop.UserData;
%         hnd.TsetCurrent.String = num2str(SetPt);
        
        %% Bloque de lectura
%         if ~stop_value   
            stopVal = 0;
            Nciclos = str2double(get(handles.Nciclos,'String'));            
            
            % Contador de ciclos de lectura de T_MC
            k = 1;
            k1 = 1;
            Rp = [];
            T_MC = [];
            while k < Nciclos+1  
%                 tic;
                % Guardamos la T_MC al empezar
%                 T_MC_old = str2double(get(handles.MCTemp,'String'));
%                 if isnan(T_MC_old)
%                     continue;
% %                     T_MC_old = str2double(get(handles.MCTemp,'String'));
%                 end
                    
%                 while T_MC_old == str2double(get(handles.MCTemp,'String')) % Que mida hasta que cambie T_MC
                    if hnd.avs.Value % Si la lectura del AVS está activada mide
                        % Lectura del AVS
%                         tic
                        [avs_Device, R_1] = avs_Device.Read;
%                         t = toc;
%                         disp(t)
                        while isempty(R_1.Value) % Protección ante lecturas vacias
                            [avs_Device, R_1] = avs_Device.Read;
                        end
                        % Mira si el ByPass está activado
                        if handles.ActivateAVSByPass.Value
                            R_1.Value = R_1.Value*handles.div/str2double(get(handles.CurrentByPass,'String'));
                        end
                        Rp(k1) = R_1.Value;
%                         R(jj).Value = R_1.Value;
                    else
                        Rp(k1) = NaN;
%                         R(jj).Value = NaN;
                    end                    
                    % Proteccion ante lecturas vacias de Temp
                    while isnan(str2double(get(handles.MCTemp,'String')))
                        StopVal = stop_meas(hnd);
                        pause(0.0005);
                    end                    
                    % Se guarda la temperatura de la mixing actual
                    T_MC(k1) = str2double(get(handles.MCTemp,'String'));  
%                     disp(['Medidas/Temp #:' num2str(k1)])
                    k1 = k1 + 1;
                    StopVal = stop_meas(hnd);
                    if StopVal == 1                        
                        break;
                    end
%                     continue;
%                 end
%                 if StopVal == 1
%                     break;
%                 end
%                 disp(['Medidas/ciclo #:' num2str(k)])
                k = k + 1;
            end
            if StopVal == 1
                break;
            end
            R(jj) = nanmean(Rp);
            Rsig(jj) = nanstd(Rp);
            T(jj) = nanmean(T_MC);
            Tsig(jj) = nanstd(T_MC);
            Pt(jj) = handles.U(1);
            Dt(jj) = toc(t);
            
%             T_MC1 = str2double(get(handles.MCTemp,'String'));
%             if isnan(T_MC1)  % Protección ante lecturas vacias
%                 continue;
%             else
%                 T_MC = T_MC1;
%             end                        
%             T(jj) = T_MC;
%             
%             k = k + 1;
%             end

            % Actualiza la gráfica con los datos nuevos
            he = findobj('Type','Line','DisplayName','Current');
            delete(he);
            %% Para probar y pasar al RT_Characterization
%             errorbar(h,T(1:jj),R(1:jj),Rsig(1:jj),'-ro','DisplayName','Current');
%             herrorbar(T(jj),R(jj),Tsig(jj));
            %%
            plot(h,T(1:jj),[R(1:jj)],'-ro','DisplayName','Current');
%             toc
            pause(0.005);
            if ~hnd.autopower.Value   
                
                if ~isequal(SetPower,hnd.SetPower)
%                 disp(hnd.SetPower);
                handles.BF.SetPower(min(hnd.SetPower,MaxPower));
                end
            end            
            
%             hnd.TsetCurrent.String = num2str(SetPt);
%             disp(jj)
            jj = jj +1;
%         else
%             hnd.Stop.UserData = 0;
%             stop(hnd.AutoPwr);
%             guidata(hnd.Stop,guidata(axes))
%             R = [R.Value];
%             return;
%         end
        
    end
    
    
end

function StopVal = stop_meas(hnd)
hnd = guidata(hnd.Stop);
StopVal = hnd.Stop.UserData;
if StopVal
    
    hnd.Stop.UserData = 0;
    stop(hnd.AutoPwr);
    guidata(hnd.Stop,guidata(hnd.Stop))        
end