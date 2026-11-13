function plotABCT(P,varargin)

nargin

warning off
if nargin==1
    %color='b';
    colors=[0 0.4470 0.7410];%%%Nuevo color por defecto en matlab
elseif nargin==2
    colors=varargin{1};
elseif nargin==3
    colors=varargin{1};
    TES=varargin{2};
    gammas=[2 0.729]*1e3; %valores de gama para Mo y Au
    rhoAs=[0.107 0.0983]; %valores de Rho/A para Mo y Au
    %sides=[200 150 100]*1e-6 %lados de los TES
    sides=TES.sides;%sides=100e-6;
    %hMo=55e-9; hAu=340e-9; %hAu=1.5e-6;
    %hMo=45e-9; hAu=270e-9; %hAu=1.5e-6;%%%1Z11.
    hMo=40e-9;hAu=220e-9;%3Z13.
    hAu=2.4e-6;%%%!!!
    %CN=(gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc; %%%Calculo directo
    CN=(gammas.*rhoAs).*([hMo hAu]*sides.^2).*TES.Tc; %%%calculo de cada contribucion por separado.
    CN=sum(CN);
    rpaux=0.1:0.01:0.9;
end


%global hc ht ha hb hl
for i=1:length(P)
    
shc=subplot(2,2,1);
[rp,jj]=sort([P(i).p.rp]);
C=abs([P(i).p(jj).C])*1e15;
%%%Filtrado para visualización
mC=median(C);
indC=find(C<3*mC & C>0.3*mC);

MS=10;%MarkerSize
LW1=1;%Linewidth

%hc(i)=plot([P(i).p(jj).rp],abs([P(i).p(jj).C])*1e15,'.-','color',color),grid on,hold on
hc(i)=plot(rp(indC),C(indC),'.-','color',colors,'linewidth',LW1,'markersize',MS);grid on,hold on
if nargin>2
    plot(rpaux,CN*1e15*ones(1,length(rpaux)),'-','color','r','linewidth',2)
    plot(rpaux,2.43*CN*1e15*ones(1,length(rpaux)),'-','color','k','linewidth',2)
end
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('C(fJ/K)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

sht=subplot(2,2,2);
[~,jj]=sort([P(i).p.rp]);
ht(i)=semilogy([P(i).p(jj).rp],[P(i).p(jj).taueff]*1e6,'.-','color',colors,'linewidth',LW1,'markersize',MS);grid on,hold on
ylim([1 1e4])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('\tau_{eff}(\mus)','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

sha=subplot(2,2,3);
[rp,jj]=sort([P(i).p.rp]);
ai=abs([P(i).p(jj).ai]);
%%%Filtrado para visualización
mai=median(ai);
%indai=find(ai<3*mai & ai>0.3*mai);
indai=1:length(ai);
%ha(i)=plot([P(i).p(jj).rp],[P(i).p(jj).ai],'.-','color',color),grid on,hold on
ha(i)=plot(rp(indai),ai(indai),'.-','color',colors,'linewidth',LW1,'markersize',MS);grid on,hold on
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('\alpha_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

shb=subplot(2,2,4);
[~,jj]=sort([P(i).p.rp]);
hb(i)=semilogy([P(i).p(jj).rp],[P(i).p(jj).bi],'.-','color',colors,'linewidth',LW1,'markersize',MS);grid on,hold on
semilogy(0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2)
ylim([1e-2 1e1])
xlabel('R_{TES}/R_n','fontsize',11,'fontweight','bold');ylabel('\beta_i','fontsize',11,'fontweight','bold');
set(gca,'fontsize',11,'fontweight','bold','linewidth',2)

% [hc(i) ht(i) ha(i) hb(i)]
brush on;
hl{i}=linkprop([hc(i) ht(i) ha(i) hb(i)],'brushdata');

%brush off;
linkaxes([shc sht sha shb],'x');
end
xlim([0.05 0.9])
set(hc,'userdata',hl);
set(ht,'userdata',hl);
set(ha,'userdata',hl);
set(hb,'userdata',hl);