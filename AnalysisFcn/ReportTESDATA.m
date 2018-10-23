function ReportTESDATA(TESDATA)

%% Pintar curvas IV
figIV.hObject = figure('Visible','off');
for i = 1:4
    h(i) = subplot(2,2,i);                
end 
Data2DrawStr(1,:) = {'ibias*1e6';'vout'};
Data2DrawStr_Units(1,:) = {'Ibias(\muA)';'Vout(V)'};
Data2DrawStr(2,:) = {'vtes*1e6';'ptes*1e12'};
Data2DrawStr_Units(2,:) = {'V_{TES}(\muV)';'Ptes(pW)'};
Data2DrawStr(3,:) = {'vtes*1e6';'ites*1e6'};
Data2DrawStr_Units(3,:) = {'V_{TES}(\muV)';'Ites(\muA)'};
Data2DrawStr(4,:) = {'rtes';'ptes*1e12'};
Data2DrawStr_Units(4,:) = {'R_{TES}/R_n';'Ptes(pW)'};

IVset = [TESDATA.IVsetP TESDATA.IVsetN];
for i = 1:length(IVset)
    if IVset(i).good        
        for j = 1:4            
            eval(['plot(h(j),IVset(i).' Data2DrawStr{j,1} ', IVset(i).' Data2DrawStr{j,2} ', ''.--'','...
                '''ButtonDownFcn'',{@ChangeGoodOpt},''DisplayName'',num2str(IVset(i).Tbath),''Tag'',IVset(i).file);']);
            grid(h(j),'on');
            hold(h(j),'on');
            xlabel(h(j),Data2DrawStr_Units(j,1),'fontweight','bold');
            ylabel(h(j),Data2DrawStr_Units(j,2),'fontweight','bold');            
        end                        
    else  % No se pinta o se pinta de otro color
        
    end
end
set(h,'fontsize',12,'linewidth',2,'fontweight','bold')
axis(h,'tight');
figIV.hObject.Visible = 'on';

%% Pintar NKGT set
clear fig;
MS = 10; %#ok<NASGU>
LS = 1; %#ok<NASGU>
color{1} = [0 0.447 0.741];
color{2} = [1 0 0]; %#ok<NASGU>
StrField = {'n';'Tc';'K';'G'};
StrMultiplier = {'1';'1';'1e-3';'1'}; %#ok<NASGU>
StrLabel = {'n';'Tc(K)';'K(nW/K^n)';'G(pW/K)'};
StrRange = {'P';'N'};
StrIbias = {'Positive';'Negative'};
for k = 1:2
    if isempty(eval(['TESDATA.Gset' StrRange{k} '.n']))
        continue;
    end
    if ~exist('fig','var')
        fig.hObject = figure;
    end
    Gset = eval(['TESDATA.Gset' StrRange{k}]);     %#ok<NASGU>
    
    TES_OP_y = find([Gset.Tc] == TESDATA.TES.Tc,1,'last');    
    if isfield(fig,'subplots')
        h1 = fig.subplots;
    end
    for j = 1:length(StrField)
        if ~isfield(fig,'subplots')
            h1(j) = subplot(2,2,j);
        end
        eval(['plot(h1(j),[Gset.rp],[Gset.' StrField{j} '],''.-'','...
            '''color'',color{k},''linewidth'',LS,''markersize'',MS,''DisplayName'',''' StrIbias{k} ''');']);
        hold(h1(j),'on');
        grid(h1(j),'on');
                
        try
            eval(['plot(h1(j),Gset(TES_OP_y).rp,Gset(TES_OP_y).' StrField{j} ',''.-'','...
            '''color'',''g'',''linewidth'',LS,''markersize'',MS*1.5,''DisplayName'',''Operation Point'');']);
        catch
        end
        xlim(h1(j),[0.15 0.9]);
        xlabel(h1(j),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
        ylabel(h1(j),StrLabel{j},'fontsize',11,'fontweight','bold');
        set(h1(j),'linewidth',2,'fontsize',11,'fontweight','bold')
    end
    
    fig.subplots = h1;
end
fig.hObject.Visible = 'on';

TESDATA.plotABCT;


