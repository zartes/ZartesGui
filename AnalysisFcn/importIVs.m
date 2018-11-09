function [IVset, Rf] = importIVs(varargin)
%funcion para importar datos de medidas IV en estructura para analisis.

if nargin == 1
    [file,path]=uigetfile([varargin{1} '*'],'Pick a Data path containing IV curves','Multiselect','on');
else
    [file,path]=uigetfile('G:\Unidades de equipo\ZARTES\DATA\*','Pick a Data path containing IV curves','Multiselect','on');
end
if iscell(file)||ischar(file)
    T=strcat(path,file);
else
    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
    return;
end


% skip=7;%header=6, +1 del primer pto. Ojo, si skip=0, se devuelve data y no data.data.
if (iscell(T))
    for i=1:length(T)
%         data = importdata(T{i},'\t',skip);
        data = importdata(T{i});
        if isstruct(data)
            data = data.data;
        end
%         data = data{i}.data;
        
        %corregir el vout.
        %auxS=corregir4ramas(data);%%para importar ficheros con 4 ramas (sin header)
        auxS = corregir1rama(data);%% para importar ficheros con 1 rama.
        auxS.Tbath = sscanf(char(regexp(file{i},'\d+.?\d+mK*','match')),'%fmK')*1e-3; %%%ojo al %d o %0.1f
        % Añadido para identificar de donde procede la informacion
        auxS.file = file{i};
        IVset(i) = auxS;
        
        %     IVset(i).ibias=data{i}(:,2)*1e-6;
        %     IVset(i).vout=data{i}(:,4)-data{i}(end,4);
        %     if nargin>0
        %         IVset(i).Tbath=varargin{1}(i);
        %     else
        %         IVset(i).Tbath=sscanf(file{i},'IV%dmK*')*1e-3;
        %     end
        ind_i = strfind(file{i},'mK_Rf');
        ind_f = strfind(file{i},'K_down_');
        if isempty(ind_f)
            ind_f = strfind(file{i},'K_up_');
        end
        Rf(i) = str2double(file{i}(ind_i+5:ind_f-1))*1000;

    end
else
    data=importdata(T);
    if isstruct(data)
        data = data.data;
    end
%     data=data.data;
    
    %corregir el vout.
    %auxS=corregir4ramas(data);%%para importar ficheros con 4 ramas (sin header)
    auxS = corregir1rama(data);%% para importar ficheros con 1 rama.
    auxS.Tbath = sscanf(char(regexp(file,'\d+.?\d+mK*','match')),'%fmK')*1e-3; %%%ojo al %d o %0.1f
    % Añadido para identificar de donde procede la informacion
    auxS.file = file;
    IVset = auxS;
    
    %     IVset.ibias=data(:,2)*1e-6;
    %     IVset.vout=data(:,4)-data(end,4);
    %     if nargin>0
    %         IVset.Tbath=varargin{1};
    %     else
    %         IVset.Tbath=sscanf(file,'IV%dmK*')*1e-3;
    %     end
    ind_i = strfind(file,'mK_Rf');
    ind_f = strfind(file,'K_down_');
    if isempty(ind_f)
        ind_f = strfind(file,'K_up_');
    end
    Rf = str2double(file(ind_i+5:ind_f-1))*1000;
end
Rf = unique(Rf);
if length(Rf) > 1
    warndlg('Unconsistency on Rf values, please check it out','ZarTES v1.0');
end

