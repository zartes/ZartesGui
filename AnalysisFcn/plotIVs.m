function fig = plotIVs(IVmeasure,varargin)
%Versión para usar como parámetros de entrada una estructura IVmeasure con
%toda la información necesaria.

%IVmeasure=GetIVTES(Circuit,IVmeasure);
% plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');
if nargin == 1
    fig.hObject = figure;
elseif nargin == 2
    fig = varargin{1};
    if isempty(fig)
        fig.hObject = figure;
    end
end

if isfield(fig,'subplots')
    h = fig.subplots;
end

j = 1;
for i = 1:length(IVmeasure)
    if isfield(IVmeasure,'good')
        good = IVmeasure(i).good;
    else
        good = 1;
    end
    if good
%         i,good
        ibias = IVmeasure(i).ibias;
        vout = IVmeasure(i).vout;%valor corregido de Vout.
        
        
%         % Se obtienen las pendientes en estado normal y superconductor
%         PN = polyfit(ibias(1:10),vout(1:10),1);
%         mN(j) = PN(1);
%         PS = polyfit(ibias(end-3:end),vout(end-3:end),1);
%         mS(j) = PS(1);
        
        
        %curva Vout-Ibias
        if ~isfield(fig,'subplots')
            h(1) = subplot(2,2,1);
        end
        
%         plot(h(1),ibias*1e6,vout,'.--','DisplayName',num2str(IVmeasure(i).Tbath));
%         data{1} = IVmeasure;
%         data{2} = i;
        h_ib(j) = plot(h(1),ibias*1e6,vout,'.--','DisplayName',num2str(IVmeasure(i).Tbath),...
            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',IVmeasure(i).file);
        grid on,hold on
        xlim(h(1),[min(0,sign(ibias(1))*500) 500]) %%%Podemos controlar apariencia con esto. 300->500
        xlabel(h(1),'Ibias(\muA)','fontweight','bold');ylabel(h(1),'Vout(V)','fontweight','bold');
        set(h(1),'fontsize',12,'linewidth',2,'fontweight','bold')
%         axis(h(1),'tight');
        
        %Curva Ites-Vtes
        if ~isfield(fig,'subplots')
            h(3) = subplot(2,2,3);
        end        
        h_ites(j) = plot(h(3),IVmeasure(i).vtes*1e6,IVmeasure(i).ites*1e6,'.--','DisplayName',num2str(IVmeasure(i).Tbath),...
            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',IVmeasure(i).file);
        grid on,hold on
        xlim(h(3),[min(0,sign(ibias(1))*.5) .5])
        xlabel(h(3),'V_{TES}(\muV)','fontweight','bold');ylabel(h(3),'Ites(\muA)','fontweight','bold');
        set(h(3),'fontsize',12,'linewidth',2,'fontweight','bold')
%         axis(h(3),'tight');
        
        %Curva Ptes-Vtes
        if ~isfield(fig,'subplots')
            h(2) = subplot(2,2,2);
        end        
        h_ptes(j) = plot(h(2),IVmeasure(i).vtes*1e6,IVmeasure(i).ptes*1e12,'.--','DisplayName',num2str(IVmeasure(i).Tbath),...
            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',IVmeasure(i).file);
        grid on,hold on
        xlim(h(2),[min(0,sign(ibias(1))*1.0) 1.0])%%%Podemos controlar apariencia con esto. 0.5->1.0
        xlabel(h(2),'V_{TES}(\muV)','fontweight','bold');ylabel(h(2),'Ptes(pW)','fontweight','bold');
        set(h(2),'fontsize',12,'linewidth',2,'fontweight','bold')
%         axis(h(2),'tight');
        
        %Curva Ptes-rtes.
        if ~isfield(fig,'subplots')
            h(4) = subplot(2,2,4);
        end   
        h_rtes(j) = plot(h(4),IVmeasure(i).rtes,IVmeasure(i).ptes*1e12,'.--','DisplayName',num2str(IVmeasure(i).Tbath),...
            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',IVmeasure(i).file);
        grid on,hold on
        xlim(h(4),[0 1]), ylim(h(4),[0 20]);
        xlabel(h(4),'R_{TES}/R_n','fontweight','bold');ylabel(h(4),'Ptes(pW)','fontweight','bold');
        set(h(4),'fontsize',12,'linewidth',2,'fontweight','bold')        
        
        j = j+1;
    end
end
axis(h,'tight');
set([h_ib h_ites h_ptes h_rtes],'UserData',IVmeasure);
linkprop([h_ib h_ites h_ptes h_rtes],'Color');
set(fig.hObject,'UserData',IVmeasure);
