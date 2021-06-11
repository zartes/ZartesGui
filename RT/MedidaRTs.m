function [R, T] = MedidaRTs(avs_Device,handles,TipoCurva,TempRange,TempStep,ToleranceError,axes)
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

CurrentStepPower = str2double(get(handles.PowerStep,'String'))*1e-3;

a = load('RefValues.mat');
BasalPower = spline(a.RefTemps,a.RefPowers*1e-6,SetPt);  % Actualizar con los datos de caracterizacion.

Error = (abs(T_MC-SetPt)/SetPt)*100;
% disp(Error);

h = axes;
xlabel(h,'T (K)')
ylabel(h,'R (Ohm)');
hold(h,'on');
avs_Device.Read;
clear R T;
P = handles.BF.P;
I = handles.BF.I;
D = handles.BF.D;

if ~handles.TemperatureControl.Value  % Control de la potencia con control PID por el BlueFors (No recomendado)
    jj = 1;
    %%  Situar el BlueFors en PID control
    handles.BF.SetPID(P,I,D);
    PID_mode = handles.BF.ReadPIDStatus;
    if ~PID_mode
        handles.BF.SetTempControl(1); %Manual
    end
        
    while abs(SetPt-TempFin) > 0.0001        
        
        hnd = guidata(axes);
        hnd.MCTemp.String = num2str(T_MC);
        hnd.TsetCurrent.String = num2str(SetPt);
        stop_value = hnd.Stop.UserData;
        
        if ~stop_value
            [avs_Device, R(jj)] = avs_Device.Read;
            while isempty(R(jj).Value)
                [avs_Device, R(jj)] = avs_Device.Read;
            end
            
            T_MC = str2double(get(handles.MCTemp,'String'));
            
            
            Error = (abs(T_MC-SetPt)/SetPt)*100;
            disp(Error);
            T(jj) = T_MC;
            he = findobj('Type','Line','DisplayName','Current');
            delete(he);
            plot(h,T(1:jj),[R(1:jj).Value],'r*','DisplayName','Current')
            if Error < ToleranceError
                
                
                
                % Cambia la temperatura Oxford
                %             vi.vi_IGHFrontPanel.FPState = 4;
                %             pause(0.1)
                %             vi.vi_IGHFrontPanel.FPState = 1;
                %             pause(0.1)
                %             vi.vi_IGHFrontPanel.SetControlValue('Settings',1);
                %             pause(1.5)
                %             vi.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
                %             pause(0.1)
                %             while strcmp(vi.vi_PromptForT.FPState,'eClosed')
                %                 pause(0.1);
                %             end
                %             vi.vi_PromptForT.SetControlValue('Set T',SetPt)%
                %             pause(0.4)
                %             vi.vi_PromptForT.SetControlValue('Set T',SetPt)%
                %             pause(0.1)
                %             vi.vi_PromptForT.SetControlValue('OK',1)
                %             pause(0.1)
                %             while strcmp(vi.vi_PromptForT.FPState,'eClosed')
                %                 pause(0.1);
                %             end
                % Bluefors
                % Añadir el cambio de temperatura o cambio de potencia.
%                 if handles.TemperatureControl.Value    % Control de la potencia mediante pasos en la temperatura de referencia
                    switch TipoCurva
                        case 'Ascendente'
                            SetPt = min(SetPt+TempStep,TempFin);
                        case 'Descendente'
                            SetPt = max(SetPt-TempStep,TempFin);
                    end
                    handles.BF.SetTemp(SetPt);
                    
                    hnd.TsetCurrent.String = num2str(SetPt);
                
            end
            jj = jj +1;
        else
            hnd.Stop.UserData = 0;
            guidata(hnd.Stop,guidata(axes))
            R = [R.Value];
            return;
        end
    end
    
    R = [R.Value];
    
    
    
    
else % Control de la potencia con control PID de forma manual
    hnd = guidata(axes);
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
    pause(1);
    

    Error = zeros(2,1);
    % La potencia de inicio se actualiza con la que tiene el heater al
    % comienzo
    Power = handles.BF.ReadPower;
    sumError = Power*I/P;
    
    jj = 1;
    while eval(CondStop)        
        
        
        hnd.MCTemp.String = num2str(T_MC);
%         CurrentStepPower = str2double(hnd.PowerStep.String)*1e-3;
        TempStep = str2double(hnd.Temp_Step.String);
        stop_value = hnd.Stop.UserData;
        hnd.TsetCurrent.String = num2str(SetPt);
        
        if ~stop_value
            % Lectura del AVS
            [avs_Device, R(jj)] = avs_Device.Read;
            while isempty(R(jj).Value)
                [avs_Device, R(jj)] = avs_Device.Read;
            end
            % Se comprueba la temperatura de la mixing
            T_MC1 = str2double(get(handles.MCTemp,'String'));
            if isnan(T_MC1)
                continue;
            else
                T_MC = T_MC1;
            end
            
            % calculo de la potencia a suministrar
            Error = [SetPt-T_MC; Error(1:end-1)];
            sumError = sumError + Error(1);
            SetPower = max(P*(Error(1) + (1/I)*sumError + D*diff(Error([2 1]))),0);
            
            
            T(jj) = T_MC;
            he = findobj('Type','Line','DisplayName','Current');
            delete(he);
            plot(h,T(1:jj),[R(1:jj).Value],'r*','DisplayName','Current')
            
            
            handles.BF.SetPower(SetPower);
            disp(SetPower)
            if (abs(T_MC-SetPt)/SetPt)*100 < ToleranceError
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
        else
            hnd.Stop.UserData = 0;
            guidata(hnd.Stop,guidata(axes))
            R = [R.Value];
            return;
        end
        
    end
    R = [R.Value];
end