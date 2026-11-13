function plotParamTES(TESDATA,xl,yl,varargin)
% Función para pintar y formatear parámetros a partir de una estructura P.
% Pinta parametro x frente a y a todas las temperaturas para un TES
% dado.


if nargin>3
    opt = varargin{1};
    optname = [opt.name,{'markersize'}];
    optvalue = [opt.value,{15}];
else
    optname = {'markersize','linestyle'};
    optvalue = {15,'-'};
end

StrRange = {'P';'N'};
for k = 1:2
    if isempty(eval(['TESDATA.P' StrRange{k} '.Tbath']))
        continue;
    end
    P = eval(['TESDATA.P' StrRange{k} ';']);
    if ~exist('fig','var')
        fig.hObject = figure('Visible','off');
        ax = axes;
    end    
    
    Field = fieldnames(P(1).p(1));
    StrVar = {'x';'y'};
    for i = 1:length(StrVar)        
        if ~isempty(cell2mat(strfind(Field,eval([StrVar{i} 'l']))))
            eval([StrVar{i} '_ini = ''' StrVar{i} ' = [P('';']);
            eval([StrVar{i} '_fin = '').p.' eval([StrVar{i} 'l']) '];'';']);
        end
    end
    
    for i = 1:length(P)
        [rp,jj] = sort([P(i).p.rp]);
        
        eval([x_ini num2str(i) x_fin]);
        eval([y_ini num2str(i) y_fin]);
        h(i,k) = plot(ax,x,y,'.','ButtonDownFcn',{@Identify_Origin},'UserData',{P;i;TESDATA.circuit});hold(ax,'on');
        
    end
    set(h,optname,optvalue);    
    grid(ax,'on');
    xlabel(ax,xl,'fontsize',12,'fontweight','bold');
    ylabel(ax,yl,'fontsize',12,'fontweight','bold');
    set(ax,'linewidth',2,'fontsize',12,'fontweight','bold');
end
fig.hObject.Visible = 'on';