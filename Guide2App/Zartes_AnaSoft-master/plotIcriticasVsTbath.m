function plotIcriticasVsTbath(varargin)
%%%Funcion para pintar los valores de Icritca medidos a cada temperatura

if nargin==0
    fauxP=ls('*_p_*');
    fauxN=ls('*_n_*');
else
    fauxP=varargin{1};
end

for i=1:length(fauxP(:,1))
    data=importdata(fauxP(i,:));
    Ic(i)=abs(data(end-1,2));%%%Tomamos valor absoluto para superponer positivas y negativas.   
    x=regexp(fauxP(i,:),'Ic_(?<temp>\d*(.\d+)?mK)','names');
    Tbath(i)=sscanf(x.temp,'%fmK')*1e-3;
end

plot(Tbath,Ic,'o-','linewidth',1,'markerfacecolor','auto')

set(gca,'fontsize',20,'fontweight','bold')
xlabel('T_{bath}(K)')
ylabel('I_{critica}(\muA)')
axis tight
grid on

if sum(~cellfun(@isempty,strfind(who,'fauxN')))
    for i=1:length(fauxP(:,1))
        data=importdata(fauxN(i,:));
    Ic(i)=abs(data(end-1,2));%%%Tomamos valor absoluto para superponer positivas y negativas.
    x=regexp(fauxN(i,:),'Ic_(?<temp>\d*(.\d+)?mK)','names');
    Tbath(i)=sscanf(x.temp,'%fmK')*1e-3;
    end
    hold on,plot(Tbath,Ic,'o-','linewidth',1,'markerfacecolor','auto')
    legend({'positive bias' 'negative bias'})
    axis tight
end