function IV = acquireIVs_updated(Temp,Ibvalues)
% Function for the acquisition of IVs. A digital multimeter (Agilent HP
% 3458A) is used for measuring a voltage (to define) proportional to ....
%
% Input:
% - Temp: milliKelvin (String), 'xxmK' string.
% - Ibvalues: number array in uA units.
% 
% Output:
% - IV.Tbath: Bath temperature of the material (units).
% - IV.ibias: currents (units).
% - IV.vout: voltages (units).
% 
% Example of usage:
% IV = acquireIVs('4mK', [500:-10:150 145:-5:100 99:-1:60 59.5:-0.5:0])
%
% Last update: 26/06/2018

%% Old version
%%%Funcion para adquirir IVs con matlab leyendo el HP3458A y con step de
%%%corriente variable. Ojo, pasar Ibias values en uA.
%%%Pasar Temp como 'xxmK' string
%%%Version 17Oct17. Paso funciones CH.
%%%Version 3Nov17. Incorporo refreshdata para pintar a la vez que adquiere.


%% Initializing parameter values

%%%QUE FUENTE SE USA
magnicon.sourceCH = 2;
setting.Rf = 1e4;

% Configuration to be stored
signo = sign(Ibvalues(1));
signo_end = sign(Ibvalues(end));
switch signo
    case 1  % from positive to less positive values
        pol = 'p';
        dire = 'down';
    case -1
        pol = 'n';
        dire = 'down';
    case 0
        if signo_end % positive
            pol = 'p';
        else
            pol = 'n';
        end
        dire = 'up';
end


%%%si queremos o no pintar la curva.
boolplot = 1;


%% Module to check if the file which is creating already exists in order not
% to overwrite it. 

f = dir;
q = regexp({f.name},'\d*.?\d*mK','match');
for i = 1:length(q)
    if(strcmp(q{i},Temp))
        QuestButton = questdlg('Warning! A file regarding temperature setting already exists! Do you want to continue overwriting the file?', ...
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
end

%% Initializing measuring devices

% Initializing the SQUID
mag = mag_init_updated();  
mag_setRf_FLL_CH_updated(mag,setting.Rf,magnicon.sourceCH);%3e3  Set a fixed value of Rf in FLL

% Initializing the multimeter HP3458A
multi = multi_init_updated(); 


%%%Ponemos el máximo de corriente 
if ~Put_TES_toNormal_State_CH_updated(mag,signo,magnicon.sourceCH)
    disp('TES status was not in the normal status');
    return;    
end

%%% Clossed loop is reset
mag_setAMP_CH_updated(mag,magnicon.sourceCH);
mag_setFLL_CH_updated(mag,magnicon.sourceCH);


slope = 0;
state = 0;
jj = 1;
averages = 1;
data = Nan(length(Ibvalues),4);

for i = 1:length(Ibvalues)
    
    disp(['Ibias: ' num2str(Ibvalues(i)) ' uA'])
    
    if slope > 3000
        state = 1;
    end %%% state = 1 -> superconductor. Be aware! slope value of 3000 is just for Rf = 3Kohm.
    
    if state && mod(Ibvalues(i),5) %%% When the state is superconductor then the resolution is changed
        continue;
    end  
    
    mag_setImag_CH_updated(mag,Ibvalues(i),magnicon.sourceCH);
    
    if i == 1
        pause(2);
    end
    pause(2.)
    
    aux1 = {[]};
    Vdc_array = Nan(1,averages);
    for i_av = 1:averages
        try
            % To verify
            aux1{i_av} = multi_read(multi);
            if i_av == averages
                Vdc = mean(cell2mat(aux1));
            end
        catch
            disp('Old alternative is running on voltage measurement procedure.')
            aux = multi_read_updated(multi);
            Vdc_array(i_av) = mean(aux);%%%a veces multi_read devuelve un array con varios valores y la asignación a v(i) da error.
            if i_av == averages
                Vdc = mean(Vdc_array);
            end
        end
    end
    
    Ireal = mag_readImag_CH(mag,magnicon.sourceCH);
    
    data(jj,1) = now;
    data(jj,2) = Ireal; %*1e-6;
    data(jj,3) = 0; %%%Vout
    data(jj,4) = Vdc;
%     x(jj) = Ireal*1e-6;
%     y(jj) = Vdc;
    jj = jj+1;
    
    % To verify
    if i > 1 && ~state 
        slope = (data(i,4)-data(i-1,4))/((data(i,2)-data(i-1,2))*1e-6);
    end
    if jj > 1 && ~state 
        slope = (data(jj,4)-data(jj-1,4))/((data(jj,2)-data(jj-1,2))*1e-6);
    end
    
    %% Este bloque hay que cambiarlo
    if boolplot
        figure;
        if i == 1
            h = plot(data(:,2)*1e-6,data(:,4),'o-k','linewidth',3); %#ok<NASGU>
            hold on;
            grid on;
%             set(h,'xdatasource','x','ydatasource','y','linestyle','-');
        end
        refreshdata(1,'caller');
    end
end


IV = corregir1rama(data);
IV.Tbath = str2double(Temp(1:end-2))*1e-3; % Temp in mK 

figure(2)
plot(IV.ibias,IV.vout,'.-');

%%%guardar datos
Rf = mag_readRf_FLL_CH_updated(mag,magnicon.sourceCH)/1000; % KOhm
file = strcat(Temp,'_Rf',num2str(Rf),'K_',dire,'_',pol,'_matlab.txt');
save(file,'data','-ascii');

%%%cerrar ficheros
fclose(mag);
delete(mag);

fclose(multi);
delete(multi);
