function plotAllPulsos(varargin)
%%%funcion para pintar y superponer los pulsos de una carpeta

dir='';
params=[];
%basename='PXI_Pulso_*';
basename='pulso_*';

for i=1:nargin
    if isstruct(varargin{i})
        params=varargin{i};
    end
    if ischar(varargin{i})
        dir=varargin{i};
    end
    if isnumeric(varargin{i});
        ind=varargin{i};
    end
end

dir
faux=ls(strcat(dir,'\',basename));

hold off

%for i=1:length(faux(:,1)); %%108:125%i=1:length(faux(:,1)) 
opt.RL=2000;
opt.SR=1e5;
ind
for i=ind;
    %pulso=importdata(strcat(dir,'\',faux(i,:)));
    file=strcat(dir,'\',faux(i,:));
    pulso=readFloatPulse(file,opt);
    if isempty(pulso)
        {'pulso' i 'vacio'}
    else
        {'pulso' i }
        L=length(pulso(:,1));
    %plot(pulso(:,1),pulso(:,2)-mean(pulso(1:round(L/10),2)),'.-'),hold on,
    plot(pulso(:,1),pulso(:,2),'.-'),hold on
    if ~isempty(params)
        A=params.A(i);
        t1=params.tau_fall(i);
        t2=params.tau_rise(i);
        t0=params.t0(i);
        dc=params.dc(i);
        fhandle=@(p,x)p(1)*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4));
        %plot(pulso(:,1),fhandle([A t1 t2 t0],pulso(:,1)),'r')
        plot(pulso(:,1),fhandle([A t1 t2 t0],pulso(:,1))+dc,'r')
        hold off
    end
    pause(1)
    end
end

set(gca,'fontsize',12,'fontweight','bold')
xlabel('t(ms)')
ylabel('V_{out}')
axis tight