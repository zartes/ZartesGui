function compareTcmodels(dn,t,Tc0,varargin)
ds=[0:500]';
%cla
hold off
plot(ds,martinis(ds,dn,t,Tc0,0))
grid on
hold on
plotusadel(dn,t,Tc0)
legend('martinis','fominov')
xlabel('ds(nm)');
ylabel('Tc(mK)');
if nargin >3
    data=varargin{1};
    plot(data(:,1),data(:,2),'k-o');
    legend('martinis','fominov','data')
    titulo=varargin{2};
    title(titulo);
end