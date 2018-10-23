

%% Analisis para obtener n, K, Tc, G y G100
DataPath = uigetdir('', 'Pick a Data path named Z(w)-Ruido');
if DataPath ~= 0
    DataPath = [DataPath filesep];
else
    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
    return;
end
% Circuit structure must be created and updated 
load([DataPath 'circuit.mat']);
% circuit = TESCircuit;
% circuit = circuit.Constructor;

% Searching only those files with positive ibias range
% TempLims = [20 90];
prompt = {'Mimimun temperature (mK):','Maximum temperature (mK):'};
name = 'Input for limiting Temp for analysis';
numlines = 1;
defaultanswer = {'20','100'};
answer = inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    TempLims = [0 Inf];
else
    TempLims(1) = str2double(answer{1});
    TempLims(2) = str2double(answer{2});
end
if any(isnan(TempLims))
    f = errordlg('Invalid temperature values!', 'ZarTES v1.0', 'modal');
    return;
end

IVsPath = uigetdir(DataPath, 'Pick a Data path named IVs');
if IVsPath ~= 0
    IVsPath = [IVsPath filesep];
else
    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
    return;
end

StrRange = {'p';'n'};
figIV = [];
for j = 1:length(StrRange) 
    
    eval([upper(StrRange{j}) 'files = ls(''' IVsPath '*_' StrRange{j} '_matlab.txt'');']);
    % Erase those that are not valid
    TempStr = nan(1,size(eval([upper(StrRange{j}) 'files']),1));
    i = 1;
    while i <= size(eval([upper(StrRange{j}) 'files']),1)
        if isnan(str2double(eval([upper(StrRange{j}) 'files(i,1)'])))
            eval([upper(StrRange{j}) 'files(i,:) = [];'])
        elseif ~isempty(strfind(eval([upper(StrRange{j}) 'files(i,:)']),'(')) %#ok<STREMP>
            eval([upper(StrRange{j}) 'files(i,:) = [];'])
        else
            Value = str2double(eval([upper(StrRange{j}) 'files(i,1:strfind(' upper(StrRange{j}) 'files(i,:),''mK_'')-1)']));
            
            if or(Value < TempLims(1),Value > TempLims(2))
                eval([upper(StrRange{j}) 'files(i,:) = [];'])
            else
                TempStr(i) = Value;
                
                % Obtenemos el valor de Rf                
%                 ind_i = strfind(eval([upper(StrRange{j}) 'files(i,:)']),'mK_Rf');                
%                 ind_f = strfind(eval([upper(StrRange{j}) 'files(i,:)']),'K_down_');
%                 if isempty(ind_f)
%                     ind_f = strfind(eval([upper(StrRange{j}) 'files(i,:)']),'K_up_');
%                 end
%                 Rf(i) = str2double(eval([upper(StrRange{j}) 'files(i,ind_i+5:ind_f-1)']))*1000;
                
                i = i+1;
            end
        end
    end
%     Rf(isnan(TempStr)) = [];
%     if length(unique(Rf)) == 1
%         circuit.Rf = mode(Rf);
%     end    
    
    TempStr(isnan(TempStr)) = [];
    % Sortening in ascending mode
    [Val,Ind] = sort(TempStr);
    eval([upper(StrRange{j}) 'files = ' upper(StrRange{j}) 'files(Ind,:);']);
    
    
    
    
    eval(['IVset' upper(StrRange{j}) ' = ImportFullIV(''' IVsPath ''',' upper(StrRange{j}) 'files,circuit);']);
    [figIV, mN, mS] = plotIVs(eval(['IVset' upper(StrRange{j})]),figIV);
    
    eval(['mN' upper(StrRange{j}) ' = mN;']);
    eval(['mS' upper(StrRange{j}) ' = mS;']);
    % Revisar las curvas IV y seleccionar aquellas para eliminar del
    % analisis
    h = helpdlg('Before closing this message, please check the IV curves','ZarTES v1.0');
    true = 1;
    while true
        pause(0.1);
        if ~ishandle(h)
            true = 0;
        end
        pause(0.1);
    end
    eval(['IVset' upper(StrRange{j}) ' = get(figIV.hObject,''UserData'');']); %#ok<UNRCH>        
end
mN = median([mNP mNN]);
mS = median([mSP mSN]);

IVset = [IVsetP IVsetN];
[mN1, mS1] = IVs_Slopes(IVset);

[Rn, Rpar] = RnCalc(mN,mS,circuit);


GsetP = fitPvsTset(IVsetP, 0.3:0.01:0.8);
GsetN = fitPvsTset(IVsetN, 0.3:0.01:0.8);

fig = plotNKGTset(GsetP); % Se deben pintar juntas
data{1} = [1 0 0];
data{2} = fig;
plotNKGTset(GsetN,data); 
pause(0.2)
waitfor(helpdlg('After closing this message, select a point for TES characterization','ZarTES v1.0'));
[X,Y] = ginput(1);
ind_rp = find([GsetP.rp] > X,1);
TESstr = {'n';'K';'Tc';'G';'G100'};
TESmult = {'1';'1e-12';'1';'1e-12';'1e-12'};
for i = 1:length(TESstr)
    eval(['val = [GsetP.' TESstr{i} '];']);
    eval(['TES.' TESstr{i} ' = val(ind_rp)*' TESmult{i} ';']);
end
TES.G0 = TES.G;
TES.Rn = Rn;



% De este punto deberia obtenerse la estructura TES
% TES.n TES.K TES.G TES.Tc TES.G100 un valor para cada uno de los
% parametros
%

%% Analisis para obtener alpha, beta, tau, tau_eff,...

% Visualizacion de las Z(w)

% Partimos de una funcion de transferencia en estado superconductor: TFS
h = msgbox('Please, provide a Transfer Function in Superconductor state.','ZarTES v1.0');
true = 0;
tic;
while toc < 10
    pause(0.1)
    isvalid(h)
    if ~ishandle(h)
        true = 1;
        break;
    end
    pause(0.1)
end    
if true
    TFS = importTF;
else % Tomamos un valor de TFS automatico
    % Extraido a partir del valor de Tc y con una Ibias cerca de cero
end

% Caso IVset positivas
P = FitZset(IVsetP,circuit,TES,TFS,IVsPath);  % deberemos incluir un parametro para que los ruidos se puedan tomar desde la DSA o la PXI
for i = 1:length(P)
    P(i).circuit = circuit;
end

ind = find(IVsPath == filesep);
NegativeBiasPath = [IVsPath(1:ind(end-1)) 'Negative Bias' filesep];
PN = FitZset(IVsetN,circuit,TES,TFS,NegativeBiasPath);
for i = 1:length(PN)
    PN(i).circuit = circuit;
end
% [zs,file,path] = plotZfiles(TFS,circuit);

% La estructura P contiene los valores de alpha, beta, tau, C, Cteorica,
% tau_eff, M excess Jonson, Mexcess phonon, ExRes (experimental
% resolution)
fig = plotABCT(P);
plotABCT(PN,fig);

TES.sides=25e-6;
fig = plotABCT(P,[],TES);
plotABCT(PN,fig,TES);

plotParamTES(P,'rp','M')
plotParamTES(P,'rp','Mph')
plotParamTES(P,'rp','ExRes')

% TESDATA = BuildDataStruct;

TESDATA.TES = TES;
TESDATA.circuit = circuit;
TESDATA.IVset = IVsetP;
TESDATA.IVsetN = IVsetN;
TESDATA.Gset = GsetP;
TESDATA.GsetN = GsetN;
TESDATA.P = P;
TESDATA.PN = PN;
TESDATA.IVsPath = IVsPath;
% datastruct.session = session;


option=BuildNoiseOptions();
option.tipo='nep';
% option.tipo='nep';
option.NoiseBaseName='\HP_noise*';%%%Pattern

plotnoiseTbathRp(TESDATA,'70mK',[0.15:0.05:0.85],option)



