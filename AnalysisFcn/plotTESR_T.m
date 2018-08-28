function plotTESR_T(Circuit,IVmeasure,TES)
%%pinta la R(T) de un TES a partir de una curva IV pasada como estructura.
%%Esta función funciona sólo para una única curva.

for i=1:length(IVmeasure)
        if isfield(IVmeasure,'good') good=IVmeasure(i).good;else good=1;end
    if good,
        if isfield(IVmeasure(i),'ttes')
               IVstruct=IVmeasure(i);
        else
            IVstruct=GetIVTES(Circuit,IVmeasure(i),TES);
        end

    plot(IVstruct.ttes,IVstruct.Rtes*1e3,'.-','DisplayName',strcat(num2str(1000*IVstruct.Tbath),'mK'));
    xlabel('T_{TES}(K)','fontsize',12,'fontweight','bold');ylabel('R_{TES}(m\Omega)','fontsize',12,'fontweight','bold');grid on,hold on
    
    legend('-DynamicLegend')
    legend('off')%%%for report
    set(gca,'fontsize',12,'fontweight','bold','linewidth',2);
    end
end