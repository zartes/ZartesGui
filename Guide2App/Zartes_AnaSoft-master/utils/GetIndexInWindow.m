function indx=GetIndexInWindow()
%%%Función para extraer automáticamente los índices de poblaciones en un
%%%scatter a partir de lo que se está mostrando en la figura actual. Ojo,
%%%sólo funciona con un único objeto-plot en la figura.
xlims=get(gca,'Xlim');
ylims=get(gca,'Ylim');

scatt=get(gca,'Children');
xdata=get(scatt,'XData');
ydata=get(scatt,'YData');

indx=find(xdata>xlims(1) & xdata<xlims(2) & ydata>ylims(1) & ydata<ylims(2));