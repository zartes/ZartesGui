function plotICpairs(varargin)
%%%%Funcion para pintar el escaneo en campo a partir de los ficheros
%%%%ICpairs

if nargin==0
    faux=ls('ICpairs*mK*')
else
    faux=varargin{1};
end

olddir=pwd;
cd(GetCloudDataDir());
colores=load('colores');
colores=colores.colores;
%colores=evalin('base','colores');%%%%ojo, hay que cargar colores antes.
fc=fieldnames(colores);
hold off
cd(olddir)

%fcal=4600;%%%muT por Amperio.
fcal=4.6e-3; %%% muT por muA.
%fcal=1;%%%Para ver los valores de corriente en bobina.
for i=1:length(faux(:,1))
    i,faux(i,:)
    load(faux(i,:));
    x=regexp(faux(i,:),'ICpairs(?<temp>\d*(.\d+)?mK)','names');
    temps{i}=x.temp;
    if isfield(ICpairs,'B');else ICpairs=ICpairs.ICpairs;end%%%
    plot([ICpairs.B]*fcal,[ICpairs.p],'.-','color',colores.(fc{mod(i-1,7)+1}),'linewidth',1,'markerfacecolor','auto');hold on %%%valido solo para 7 curvas.
    plot([ICpairs.B]*fcal,[ICpairs.n],'.-','color',colores.(fc{mod(i-1,7)+1}),'linewidth',1,'markerfacecolor','auto');
    %{faux(i,:)  fc{i}}
end

h=get(gca,'children');
legend(h(end:-2:2),temps);
axis tight
set(gca,'fontsize',20,'fontweight','bold')
xlabel('B_{field}(\muT)')
ylabel('I_{critica}(\muA)')
grid on
    