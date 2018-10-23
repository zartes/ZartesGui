function fig = plotABCT(TESDATA)

warning off

colors{1} = [0 0.4470 0.7410];
colors{2} = [1 0.5 0.05];

MS = 10;
LW1 = 1;
if ~isempty(TESDATA.TES.sides)
    gammas = [2 0.729]*1e3; %valores de gama para Mo y Au
    rhoAs = [0.107 0.0983]; %valores de Rho/A para Mo y Au
    %sides = [200 150 100]*1e-6 %lados de los TES
    sides = TESDATA.TES.sides;%sides = 100e-6;
    hMo = 55e-9; hAu = 340e-9; %hAu = 1.5e-6;
    %CN = (gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc; %%%Calculo directo
    CN = (gammas.*rhoAs).*([hMo hAu]*sides.^2).*TESDATA.TES.Tc; %%%calculo de cada contribucion por separado.
    CN = sum(CN);
    rpaux = 0.1:0.01:0.9;
end
YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
DataStr = {'rp(indC),C(indC)';'[P(i).p(jj).rp],[P(i).p(jj).taueff]*1e6';...
    'rp(indai),ai(indai)';'[P(i).p(jj).rp],[P(i).p(jj).bi]'};
DataStr_CI = {'C_CI(indC)';'[P(i).p(jj).taueff_CI]*1e6';...
    'ai_CI(indai)';'[P(i).p(jj).bi_CI]'};

PlotStr = {'plot';'semilogy';'plot';'semilogy'};


StrRange = {'P';'N'};
for k = 1:2
    if isempty(eval(['TESDATA.P' StrRange{k} '.Tbath']))
        continue;
    end
    P = eval(['TESDATA.P' StrRange{k} ';']);
    if ~exist('fig','var')
        fig.hObject = figure('Visible','off');
    end
    if ~isfield(fig,'subplots')
        h = nan(4,1);
        for i = 1:4
            h(i) = subplot(2,2,i,'Visible','off');
        end
    else
        h = fig.subplots;
    end
    %global hc ht ha hb hl
    for i = 1:length(P)
        if mod(i,2)
            MarkerStr(i) = {'.-'};
        else
            MarkerStr(i) = {'.-.'};
        end
        TbathStr = [num2str(P(i).Tbath*1e3) 'mK-']; %mK
        signo = sign(sscanf(char(regexp(P(i).fileZ{1},'-?\d+.?\d+uA','match')),'%fuA')*1e-6);
        if signo == 1
            NameStr = [TbathStr 'PosIbias'];
        else
            NameStr = [TbathStr 'NegIbias'];
        end
        %     shc = subplot(2,2,1);
        [rp,jj] = sort([P(i).p.rp]);
        
        C = abs([P(i).p(jj).C])*1e15;
        C_CI = abs([P(i).p(jj).C_CI])*1e15;
        %%%Filtrado para visualización
        mC = nanmedian(C);
        %     indC = find(C < 3*mC & C > 0.3*mC);
        indC = 1:length(C);
        
        ai = abs([P(i).p(jj).ai]);
        ai_CI = abs([P(i).p(jj).ai_CI]);
        %%%Filtrado para visualización
        mai = nanmedian(ai);
        %     indai = find(ai < 3*mai & ai > 0.3*mai);
        indai = 1:length(ai);
        
        for j = 1:4
            
            eval(['errorbar(h(' num2str(j) '),' DataStr{j} ',' DataStr_CI{j} ');']);
            eval(['h_ax(' num2str(i) ',' num2str(j) ') = ' PlotStr{j} '(h(' num2str(j) '),' DataStr{j} ...
                ',''' MarkerStr{i} ''',''color'',colors{k},''linewidth'',LW1,''markersize'',MS,''DisplayName'',''' NameStr ''''...
                ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;TESDATA.circuit}]);']);
            eval(['grid(h(' num2str(j) '),''on'');']);
            eval(['hold(h(' num2str(j) '),''on'');']);
            eval(['xlabel(h(' num2str(j) '),''R_{TES}/R_n'',''fontsize'',11,''fontweight'',''bold'');']);
            eval(['ylabel(h(' num2str(j) '),''' YLabels{j} ''',''fontsize'',11,''fontweight'',''bold'');']);
            eval(['set(h(' num2str(j) '),''fontsize'',11,''fontweight'',''bold'');']);
            eval(['axis(h(' num2str(j) '),''tight'');']);
        end
        %     brush on;
        %     linkprop(h_ax(i,:),'brushdata');
        
        %brush off;
        linkaxes(h,'x');
    end
    
    if ~isfield(fig,'subplots')
        %
        semilogy(h(4),0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2,'DisplayName','Beta^{teo}');
        if ~isempty(TESDATA.TES.sides)
            plot(h(1),rpaux,CN*1e15*ones(1,length(rpaux)),'-.','color','r','linewidth',2,'DisplayName','{C_{LB}}^{teo}')
            plot(h(1),rpaux,2.43*CN*1e15*ones(1,length(rpaux)),'-.','color','k','linewidth',2,'DisplayName','{C_{UB}}^{teo}')
        end
    end
    fig.subplots = h;
    xlim([0.15 0.9])
end
fig.hObject.Visible = 'on';
    
    
%     %hc(i) = plot([P(i).p(jj).rp],abs([P(i).p(jj).C])*1e15,'.-','color',color),grid on,hold on
%     hc(i) = plot(h(1),rp(indC),C(indC),'.-','color',colors,'linewidth',LW1,'markersize',MS);
%     grid(h(1),'on');hold(h(1),'on');
%     
%     xlabel(h(1),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
%     ylabel(h(1),'C(fJ/K)','fontsize',11,'fontweight','bold');
%     set(h(1),'fontsize',11,'fontweight','bold','linewidth',2)
%     axis(h(1),'tight');
%     
%     if ~isfield(fig,'subplots')
%         h(2) = subplot(2,2,2);
%     end    
% %     sht = subplot(2,2,2);
%     
%     ht(i) = semilogy(h(2),[P(i).p(jj).rp],[P(i).p(jj).taueff]*1e6,'.-','color',colors,'linewidth',LW1,'markersize',MS);
%     grid(h(2),'on');hold(h(2),'on');
%     ylim(h(2),[1 1e4])
%     xlabel(h(2),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
%     ylabel(h(2),'\tau_{eff}(\mus)','fontsize',11,'fontweight','bold');
%     set(h(2),'fontsize',11,'fontweight','bold','linewidth',2)
%     axis(h(2),'tight');
%     
%     if ~isfield(fig,'subplots')
%         h(3) = subplot(2,2,3);
%     end
% %     sha = subplot(2,2,3);
%     
%     %ha(i) = plot([P(i).p(jj).rp],[P(i).p(jj).ai],'.-','color',color),grid on,hold on
%     ha(i) = plot(h(3),rp(indai),ai(indai),'.-','color',colors,'linewidth',LW1,'markersize',MS);
%     grid(h(3),'on');hold(h(3),'on');
%     xlabel(h(3),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
%     ylabel(h(3),'\alpha_i','fontsize',11,'fontweight','bold');
%     set(h(3),'fontsize',11,'fontweight','bold','linewidth',2)
%     axis(h(3),'tight');
%     
%     if ~isfield(fig,'subplots')
%         h(4) = subplot(2,2,4);
%     end
% %     shb = subplot(2,2,4);
%     [~,jj] = sort([P(i).p.rp]);
%     hb(i) = semilogy(h(4),[P(i).p(jj).rp],[P(i).p(jj).bi],'.-','color',colors,'linewidth',LW1,'markersize',MS);
%     grid(h(4),'on');hold(h(4),'on');
%     semilogy(h(4),0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2);
%     ylim(h(4),[1e-2 1e1]);
%     xlabel(h(4),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
%     ylabel(h(4),'\beta_i','fontsize',11,'fontweight','bold');
%     set(h(4),'fontsize',11,'fontweight','bold','linewidth',2)
%     axis(h(4),'tight');
    % [hc(i) ht(i) ha(i) hb(i)]
    
    
% set(h_ax,'UserData',hl);
% set(hc,'userdata',hl);
% set(ht,'userdata',hl);
% set(ha,'userdata',hl);
% set(hb,'userdata',hl);