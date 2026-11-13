function plotParamTES(P,xl,yl,varargin)
%%%Función para pintar y formatear parámetros a partir de una estructura P.
%%%% Pinta parametro x frente a y a todas las temperaturas para un TES
%%%% dado.

%xl='ai';
%yl='M';

if nargin>3
    opt=varargin{1};
    optname=[opt.name,{'markersize'}];
    optvalue=[opt.value,{15}];
else
    optname={'markersize','linestyle','linewidth'};
    optvalue={15,'-',1};
end

%%%In case of taueff, Zinf or Z0
if strcmp(yl,'Zinf') index=1;end
if strcmp(yl,'Z0') index=2;end
if strcmp(yl,'taueff') index=3;end
if strcmp(yl,'geff') index=4;end
if strcmp(yl,'t_1') index=5;end
    
%if strcmp(yl,'taueff')||strcmp(yl,'Zinf')||strcmp(yl,'Z0')
if any(strcmp(yl,{'Zinf' 'Z0' 'taueff' 'geff' 't_1'}))    
    for i=1:length(P),
        lb=[];ub=[];for jj=1:length([P(i).p]) lb(jj)=P(i).residuo(jj).ci(index,1);ub(jj)=P(i).residuo(jj).ci(index,2);end
        x=GetPparam(P(i).p,xl);
        y=GetPparam(P(i).p,yl);
        h=plot(x,y,'.');hold on
        %h=errorbar(x,y,ub-lb);hold on
        set(h,optname,optvalue);
    end
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
    grid on
    return;
end

if strcmp(yl,'zinf')
    for i=1:length(P),
        lb=[];ub=[];for jj=1:length([P(i).p]) lb(jj)=P(i).residuo(jj).ci(1,1);ub(jj)=P(i).residuo(jj).ci(1,2);end
        x=GetPparam(P(i).p,xl);
        y=GetPparam(P(i).p,yl);
        %h=plot(x,y,'.');hold on
        h=errorbar(x,y,ub-lb);hold on
        set(h,optname,optvalue);
    end
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
    grid on
    return;
end

resTHR=Inf;
%resTHR=0.2;

for i=1:length(P),
    %x=eval(strcat('[','P(i).p.',xl,']'));
    %y=eval(strcat('[','P(i).p.',yl,']'));
    if isstruct(P(i).residuo) 
        ind=find([P(i).residuo.resN]<resTHR);
    else
        ind=find([P(i).residuo]<resTHR);
    end
    
    %%%condicion extra
    %rr=[0.14 0.2];%%%rango 
    rr=[0 1];
    ind=find([P(i).p.rp]>rr(1)&[P(i).p.rp]<rr(2));
    
    x=GetPparam(P(i).p,xl);
    y=GetPparam(P(i).p,yl);
%    ind=1:length(x);
    h=plot(x(ind),y(ind),'.');hold on
    set(h,optname,optvalue);
end

%hold off,grid on
grid on
xlabel(xl,'fontsize',12,'fontweight','bold');
ylabel(yl,'fontsize',12,'fontweight','bold');
set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');