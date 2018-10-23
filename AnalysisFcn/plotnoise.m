function noise=plotnoise(varargin)
if nargin==0
    models={'wouter', 'irwin'};
else
    models=varargin(1);
    if nargin>1
        TES=varargin{2};
        OP=varargin{3};
        circuit=varargin{4};
    end
    if nargin==5
        M=varargin{5};
    end
end
f=logspace(0,6,1000);
n=length(models);
for i=1:n
%subplot(1,n,i) %util para comparar Irwin y wouter, pero estorba en
%plotnoiseFiles.
if nargin<=1
    noise=noisesim(models{i});
elseif nargin==4
    noise=noisesim(models{i},TES,OP,circuit);
elseif nargin==5
    noise=noisesim(models{i},TES,OP,circuit,M);
end

%noise.squid=3e-12*ones(1,length(f));

% loglog(f,noise.jo,f,noise.ph,f,noise.sh,f,noise.squid,f,noise.sum+noise.squid)
% grid on
% title(models{i})
% axis([1 1e5 1e-12 2e-10])
% h=get(gca,'children');
% set(h(1),'linewidth',3)
% legend('jhonson','phonon','shunt','squid','total')

totnoise=sqrt(noise.sum.^2+noise.squidarray.^2); %%%Hasta 20Mar2017 sumaba norma 1.
%totnoise=noise.sum+noise.squid+noise.max;
%loglog(f,noise.NEP*1e18)

loglog(f,totnoise*1e12)  %%%COMENT AND UNCOMMENT TO TOGGLE COMPONENTS
%axis([10 1e5 1e-11 1e-9])
axis([1 1e5 10 1000])
ylabel('pA/Hz^{0.5}')
%loglog(f,totnoise*1e12,f,noise.jo*1e12,f,noise.ph*1e12,f,noise.sh*1e12)%%uncomment para mostrar componentes
%legend('exp','total','jhonson','phonon','shunt')%%uncomment para mostrar componentes

h=get(gca,'children');
set(h(1),'linewidth',3);
%loglog(f,noise.max*1e12,'k');
%         subplot(1,2,2)
%         noise=noisesim('irwin');
%         loglog(f,noise.jo,f,noise.ph,f,noise.sh,f,noise.sum)
%         grid on
%         title('irwin')
%         axis([1 1e5 1e-12 1e-10])
%         h=get(gca,'children')
%         set(h(1),'linewidth',3)
%         legend('jhonson','phonon','shunt','total')
end
