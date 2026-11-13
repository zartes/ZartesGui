function buildIVfullset(h,Circuit)
%funcion para pintar todo un set de parametros de IVs a partir de los datos
%de una grafica medida. Sirve para poder pintar de golpe todos los datos
%Vout-Ibias y poder eliminar curvas 'malas' a mano y a partir del handle de
%esa grafica sacar las curvas del TES automaticamente.

%h=get(f,'children');

%parametros
Rf=Circuit.Rf;%1e3;
Rpar=Circuit.Rpar;%0.31e-3;
Rsh=Circuit.Rsh;%2e-3;
Rn=Circuit.Rn;%35.8e-3;
invMin=Circuit.invMin;%24.1;
invMf=Circuit.invMf;%66;

figure
subplot(2,2,1)
for i=1:length(h)
    subplot(2,2,1)
    x=get(h(i),'xdata');
    y=get(h(i),'ydata');
    plot(x*1e6,y,'.-'),hold on %%%ibias en uA
    ites=y*invMin/(invMf*Rf);
    vtes=(x-ites)*Rsh-ites*Rpar;
    ptes=vtes.*ites;
    Rtes=vtes./ites;
    rtes=Rtes/Rn;
    subplot(2,2,2),plot(vtes*1e6,ites*1e6,'.-'),hold on;%%%vtes en uV e ites en uA
    subplot(2,2,3),plot(vtes*1e6,ptes*1e12,'.-'),hold on;%%%ptes en pW
    subplot(2,2,4),plot(rtes,ptes*1e12,'.-'),hold on;
end  
subplot(2,2,1),title('V_{out} vs I_{bias}','fontsize',11,'fontweight','bold'),xlabel('I_{bias}(\muA)','fontsize',11,'fontweight','bold'),ylabel('V_{out}(V)','fontsize',11,'fontweight','bold'),grid on
FormatMultiplePlot(get(gca,'children'));
set(gca,'fontsize',12,'linewidth',2)
subplot(2,2,2),title('I_{tes} vs V_{tes}','fontsize',11,'fontweight','bold'),xlabel('V_{tes}(\muV)','fontsize',11,'fontweight','bold'),ylabel('I_{tes}(\muA)','fontsize',11,'fontweight','bold'),grid on
FormatMultiplePlot(get(gca,'children'));
set(gca,'fontsize',12,'linewidth',2)
subplot(2,2,3),title('P_{tes} vs V_{tes}','fontsize',11,'fontweight','bold'),xlabel('V_{tes}(\muV)','fontsize',11,'fontweight','bold'),ylabel('P_{tes}(pW)','fontsize',11,'fontweight','bold'),grid on
FormatMultiplePlot(get(gca,'children'));
set(gca,'fontsize',12,'linewidth',2)
subplot(2,2,4),title('Ptes vs R_{tes}%','fontsize',11,'fontweight','bold'),xlabel('R_{tes}%','fontsize',11,'fontweight','bold'),ylabel('P_{tes}(pW)','fontsize',11,'fontweight','bold'),grid on
FormatMultiplePlot(get(gca,'children'));
set(gca,'fontsize',12,'linewidth',2)
