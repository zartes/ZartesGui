function plotIVs(Circuit,IVmeasure)
%Versión para usar como parámetros de entrada una estructura IVmeasure con
%toda la información necesaria.

%IVstruct=GetIVTES(Circuit,IVmeasure);
IVstruct=IVmeasure;
% plot(vtes,ites,'.--'),grid on,hold on
% xlabel('Vtes(V)');ylabel('Ites(A)');


for i=1:length(IVstruct)
    
    if isfield(IVstruct,'good') good=IVstruct(i).good;else good=1;end
if good,
    i,good
ibias=IVstruct(i).ibias;
vout=IVstruct(i).vout;%valor corregido de Vout.

%curva Vout-Ibias
subplot(2,2,1);plot(ibias*1e6,vout,'.-','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlim([min(0,sign(ibias(1))*500) 500]) %%%Podemos controlar apariencia con esto. 300->500
xlabel('Ibias(\muA)','fontweight','bold');ylabel('Vout(V)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ites-Vtes
subplot(2,2,3);plot(IVstruct(i).vtes*1e6,IVstruct(i).ites*1e6,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlim([min(0,sign(ibias(1))*.5) .5])
xlabel('V_{TES}(\muV)','fontweight','bold');ylabel('Ites(\muA)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ptes-Vtes
subplot(2,2,2);plot(IVstruct(i).vtes*1e6,IVstruct(i).ptes*1e12,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlim([min(0,sign(ibias(1))*1.0) 1.0])%%%Podemos controlar apariencia con esto. 0.5->1.0
xlabel('V_{TES}(\muV)','fontweight','bold');ylabel('Ptes(pW)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')

%Curva Ptes-rtes.
subplot(2,2,4);plot(IVstruct(i).rtes,IVstruct(i).ptes*1e12,'.--','DisplayName',num2str(IVstruct(i).Tbath)),grid on,hold on
xlim([0 1]), ylim([0 20]);
xlabel('R_{TES}/R_n','fontweight','bold');ylabel('Ptes(pW)','fontweight','bold');
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')
end
end