function Full_ACQ_updated(file,circuit,varargin)

% Function for the acquisition of intensity-voltage (I-V) and impedance (Z(w))
% at a certain bath temperature value of the material.
%
% Input:
%   - file: contains the bath temperature values (in Kelvin degrees) shared with
%           the temperature control setup. file is a string with the path
%           and name of the file.
%   - circuit:
%   - varargin:
%
% Example of usage:
% Full_ACQ(file,circuit,varargin)
%
% Last update 26/06/2018

%%
% Función para adquirir IVs y Z(w) a varias temperaturas de forma
% automática a través de un fichero de comunicación compartido con el
% control de temperatura. Necesitamos pasar el circuit con Rn si queremos
% que se cargue la estructura IVset completa con la que poder extraer los
% valores de IZvalues a %Rn determinados. Eso implica medir una IV en
% estado S y otra en estado N para sacar Rpar y Rn.

% Versión 1. Con ficheros vacíos de distinto nombre
% Parametro de entrada fichero con lista de Tbaths


%% Module to evaluate the correct input values parsing
if ~ischar(file)
    disp('file input must be a string');
    return;
end
if circuit
    
end

if nargin > 2
    ivauxP = varargin{1};
end
if nargin > 3
    ivauxN = varargin{2};
end

%% Initializing parameters

basedir = pwd;

%% Adding set paths to include all functions



%% Module to read temperature values
[fid, errmsg] = fopen(file);
% In the case of error openning the file, function aborts
if fid < 0
    disp(errmsg);
    return
end
temps = fscanf(fid,'%f'); % In Kelvin degree units
temps = temps*1e3; % Now temps array is in milliKelvin
fclose(fid);


%% Main block (repeated for each temperature value)

% - Intensity-Voltage acquisition block 
% - Critical intensities acquisition block (Optional)
% - Acquisition block varying magnetic field values
% - Impedance + noise (Z(w)+ N) acquisition block
%   - Acquire or not an IV coarse (Optional)


for i = 1:length(temps)
    
    % Generating a temporal file to (specify what for)
    Tstring = sprintf('%0.1fmK',temps(i));
    SETstr = ['tmp\T' Tstring '.stb'];
    
    % Waiting for Tbath set file
    while(~exist(SETstr,'file'))
        pause(0.1);
    end
    
    % Intensity-Voltage acquisition block 
    
    IbiasValues = [500:-10:150 145:-5:100 99:-1:60 59.5:-0.5:0];%%%!!!!Crear funcion!!!!
    
    % Only in those cases were temps(i) matchs with any ivsarray then
    % acquisition is started
    ivsarray = [];
    if(~isempty(find(ivsarray == temps(i), 1))) % alternative any(ivsarray-temps(i) == 0)        
        % A new directory is generated if it does not exist
        succ = mkdir(basedir,'IVs');
        if succ == 0
            disp('Error creating the IVs folder!');
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
        else
            % Matlab current folder is changed by the IVs one
            eval(['cd ' basedir filesep 'IVs']);            
            
            try
                IVaux = acquire_Pos_Neg_Ivs_updated(Tstring, IbiasValues);
            catch % In case of device communication time out
                instrreset;
                IVaux = acquire_Pos_Neg_Ivs_updated(Tstring, IbiasValues);
            end
            
            % Matlab current folder is again changed by the "basedir"
            eval(['cd ' basedir]);
        end
    end
    
    % Critical intensities acquisition block (Optional)
    %%%temps(i)>0.080
    if(0) 
        % A new directory is generated if it does not exist
        succ = mkdir(basedir, 'ICs');
        if succ == 0
            disp('Error creating the ICs folder!');
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
        else
            % Matlab current folder is changed by the ICs one
            eval(['cd ' basedir filesep 'ICs']); 
            
            ic(i) = measure_Pos_Neg_Ic(Tstring, Ivalues);
            
            % Matlab current folder is again changed by the "basedir"
            eval(['cd ' basedir]);
        end
    end
    
    
    % Acquisition block varying magnetic field values
    
    %auxarrayIC=[0.06 0.065 0.075];
    auxarrayIC = [];
    if(~isempty(find(auxarrayIC == temps(i), 1))) % any(auxarrayIC-temps(i) == 0)
        Bvalues = (0:40:2500)*1e-6;
        ICpairs = Barrido_fino_Ic_B(Bvalues); %#ok<NASGU>
        icstring = ['ICpairs' Tstring];
        save(icstring, 'ICpairs');
    end
    
    
    % Impedance + noise (Z(w)+ N) acquisition block    
    % Temperature setup could be a subset of temp values at I-V block
        
    auxarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.070 0.075];
    if(~isempty(find(auxarray == temps(i), 1)))
        
        if(0) %%%adquirir o no una IV coarse. nargin==2   
            %imin=90-5*(i);%%%ojo si se reejecuta. Asume 50,55,70,75 i=1:4.
            IbiasCoarseValues = [500:-5:200 198:-2:85 10:-1:0];
            succ = mkdir(basedir,'IVcoarse');
            if succ == 0
                disp('Error creating the IVcoarse folder!');
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
            else
                % Matlab current folder is changed by the IVcoarse one
                eval(['cd ' basedir filesep 'IVcoarse']);
                
                try  %%%A veces dan error las IVcoarse. pq?
                    IVaux = acquire_Pos_Neg_Ivs(Tstring, IbiasCoarseValues);
                catch
                    instrreset;
                    IVaux = acquire_Pos_Neg_Ivs(Tstring, IbiasCoarseValues);
                end
                % Matlab current folder is again changed by the "basedir"
                eval(['cd ' basedir]);
            end
        end
        
        
        % Impedance acquisition begins from the Tbath folder and come back
        % to the "basedir" folder.
        
        %%%  Automatizar definición de los IZvalues !!!
        succ = mkdir(basedir, Tstring);
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
        else
            % Matlab current folder is changed by the Tstring one
            eval(['cd ' basedir filesep Tstring]);
        end
        
                
        if nargin == 2
            IVsetP = GetIVTES(circuit,IVaux.ivp);%%%nos quedamos con la IV de bias positivo.
            IVsetN = GetIVTES(circuit,IVaux.ivn);
        else
            IVsetP = ivauxP(GetTbathIndex(temps(i),ivauxP,ivauxP));
            IVsetN = IVsetP;
            IVsetN.ibias = -IVsetP.ibias;
            IVsetN.vout = -IVsetP.vout; %%% ad hoc
            
            if nargin > 3 
                IVsetN = ivauxN(GetTbathIndex(temps(i),ivauxN,ivauxN));
            end
        end
        
        rpp = (0.95:-0.05:0.01); %%%Vector con los puntos donde tomar Z(w).
        if temps(i) == 0.050 || temps(i) == 0.07
            rpp = [0.9:-0.05:0.2 0.19:-0.01:0.1];
        end
        rpn = (0.90:-0.1:0.1);
        IZvaluesP = BuildIbiasFromRp(IVsetP,rpp);
        IZvaluesN = BuildIbiasFromRp(IVsetN,rpn);
        try
            hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%ojo, se sube un nivel
            
            % Matlab current folder is changed by the IVcoarse one
            eval(['cd ' basedir filesep Tstring]);
            
            pxi_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%se sube tb un nivel
        catch
            % Matlab current folder is again changed by the "basedir"
            eval(['cd ' basedir]);  %% To check! 
        end
        %cd .. %%%(en acq Z(w) se sube ya un nivel.)  % Esto tiene que
        %estar más controlado
    end
    
    DONEstr = ['T' Tstring '.end'];
    eval('cd tmp');  %% To check! 
    
    f = fopen(DONEstr, 'w');
    if f < 0
        disp(errmsg);
        return
    end
    fclose(f);
    % Matlab current folder is again changed by the "basedir"
    eval(['cd ' basedir]);
end



%%%%Versión cero con fichero de intercambio
% fid=fopen(file,'rt+')
%
% while (~feof(fid))
%     ftell(fid)%
%     s=fgetl(fid)
%     Temp=sscanf(s,'%f')
%     Tstring=sprintf('%dmK',Temp*1e3)
%     setbool=isempty(strfind(s,'SET'))
%     while setbool
%         %%%bucle de espera al SET temperature.
%
%     end
%     if strfind(s,'SET')
%         mkdir IVs
%         cd IVs
%         %%%acquireIVs. Automatizar definición de los IbiasValues.
%         %%%Ibias.Ib130=[500:-20:240 235:-5:135 134:-0.5:90 80:-20:0]
%         %%%acquire_Pos_Neg_Ivs('130mK',Ibias.Ib130)
%         cd ..
%         mkdir Z(w)-Ruido
%         cd Z(w)-Ruido
%         mkdir(Tstring)
%         %%%acquire Z(w). Automatizar definición de los IZvalues
%         %%%IZvalues.i135=BuildIbiasFromRp(IVset(18),[0.9:-0.1:0.1])
%         %%%hp_auto_acq_POS_NEG(IZvalues.i135)
%         cd ..
%         %fprintf(fid,'%s','DONE')
%     end
% end
%
% fclose(fid)