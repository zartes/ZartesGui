function fig = plotNKGTset(TESDATA) %#ok<INUSD>

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
    if isfield(fig,'subplots')
        h = fig.subplots;
    end
    for j = 1:length(StrField)
        if ~isfield(fig,'subplots')
            h(j) = subplot(2,2,j);
        end
        eval(['plot(h(j),[Gset.rp],[Gset.' StrField{j} '],''.-'','...
            '''color'',color{k},''linewidth'',LS,''markersize'',MS,''DisplayName'',''' StrIbias{k} ''');']);hold on; grid on;
        xlim(h(j),[0.15 0.9]);
        xlabel(h(j),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
        ylabel(h(j),StrLabel{j},'fontsize',11,'fontweight','bold');
        set(h(j),'linewidth',2,'fontsize',11,'fontweight','bold')
    end
    
    fig.subplots = h;
end
if ~exist('fig','var')
    warndlg('TESDATA.fitPvsTset must be firstly applied.','ZarTES v1.0')
    fig = [];
end
