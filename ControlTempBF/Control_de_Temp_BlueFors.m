function handles = Control_de_Temp_BlueFors

% Connection to BlueFors program for controlling mix chamber temperature
    handles.BF = BlueFors;
    handles.BF = handles.BF.Constructor;      
    
    % Pasar a modo manual del BlueFors
    PID_mode = handles.BF.ReadPIDStatus;
    if PID_mode
        handles.BF.SetTempControl(0); %Manual
    end
    pause(1);
    
    T_MC = handles.BF.ReadTemp;
    handles.MCTemp.String = num2str(T_MC);

    Period = 5;
    handles.Control_timer = timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', Period, ...                        % Initial period is 1 sec.
        'TimerFcn', {@Control_Temp},'UserData',handles,'Name','ControlT');
    start(handles.Control_timer);  
    
    
    
    
    function Control_Temp(src,evnt)
        
        handles = src.UserData;
        
        T_MC = handles.BF.ReadTemp;
        SetTemp = handles.BF.ReadSetPoint;
        
        Error = zeros(2,1);
        % La potencia de inicio se actualiza con la que tiene el heater al
        % comienzo
        P = handles.BF.P;
        I = handles.BF.I;
        D = handles.BF.D;
        Power = handles.BF.ReadPower;
        sumError = Power*I/P;
        
        % calculo de la potencia a suministrar
        Error = [SetTemp-T_MC];
        sumError = sumError + Error(1);
        SetPower = max(P*(Error(1) + (1/I)*sumError  ),0);
        
        handles.BF.SetPower(SetPower);
        disp(SetTemp);