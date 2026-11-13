function [ztes,file,path]=plotZfiles(TFS,circuit,varargin)
%plot Ztes at different OP from files a partir de TFS y L.
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
L=circuit.L;
%Rsh=2e-3;
%Rpar=0.12e-3;

%[file,path]=uigetfile('C:\Users\Carlos\Desktop\ATHENA\medidas\TES\2016\May2016\Mayo2016_pcZ(w)\Z(w)\*','','Multiselect','on');
[file,path]=uigetfile('C:\Users\Carlos\Desktop\LastTESdir\TF*','*','Multiselect','on');

%file
T=strcat(path,file);
%ind=1:801;%
if nargin>2,
    ind=varargin{1};
    if nargin>3,
    for i=1:length(varargin)-1
        h(i)=varargin{i+1};
    end
    end
    %h(1)=figure;
    %h(2)=figure;
else
    ind=1:length(TFS.f);
    %ind=50:length(TFS.f)-3000;

h(1)=figure;
h(2)=figure;
end
    %ind=find(TFS.f<3 | TFS.f>5);%%%Indices para el 1Z10_45A
%if ~iscell(T), T{1}=T;end

if (iscell(T))
for i=1:length(T),
    data{i}=importdata(T{i});%size(data{i})
    tf{i}=data{i}(:,2)+1i*data{i}(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data{i}(:,1)*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
    %ztes{i}=1.0*((TFS.tf./tf{i}-1).*Rth);
    
            Cp=0e-3;
            Zth=Rsh./(1+2*pi*Cp*data{i}(:,1)*1i*Rsh)+Rpar+2*pi*L*data{i}(:,1)*1i;
            ztes{i}=(TFS.tf./tf{i}-1).*Zth;

    %T{i}
%     figure(h(1)),plot(ztes{i}(ind),'.'),grid on,hold on,
%     xlabel('Re(Z)');ylabel('Im(Z)'),title('Ztes with fits (red)');
%     figure(h(2)),semilogx(data{i}(:,1),real(ztes{i}(ind)),'.',data{i}(:,1),imag(ztes{i}(ind)),'.r'),hold on
    
    figure(h(1)),plot(1e3*ztes{i}(ind),'.-b','markerfacecolor','b','markersize',6),grid on,hold on;%%% Paso marker de 'o' a '.'
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
    xlabel('Re(mZ)','fontsize',12,'fontweight','bold');ylabel('Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
    figure(h(2)),semilogx(data{i}(ind,1),real(ztes{i}(ind)),'.-',data{i}(ind,1),imag(ztes{i}(ind)),'.-r'),hold on

    xlabel('Freq(Hz)(Z)');title('Real (blue) and Imaginary (red) parts of Ztes with fits (black)');
    ztes{i}=ztes{i}(ind);
end
else
    data=importdata(T);
    tf=data(:,2)+1i*data(:,3);%%%!!!ojo al menos.
    Rth=Rsh+Rpar+2*pi*L*data(:,1)*1i;%*1i;
    %tf{i}=conj(tf{i});
    %size(TFS),size(tf{i}),size(Rth)
     ztes=(TFS.tf./tf-1).*Rth;
%     figure(h(1)),plot(ztes(ind),'.'),hold on,
%     figure(h(2)),semilogx(data(ind,1),real(ztes(ind)),'.',data(ind,1),imag(ztes(ind)),'.r'),hold on
    
        figure(h(1)),plot(1e3*ztes(ind),'.-','markerfacecolor','b','markersize',6),grid on,hold on;%%% Paso marker de 'o' a '.'
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
    xlabel('Re(mZ)','fontsize',12,'fontweight','bold');ylabel('Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
    figure(h(2)),semilogx(data(ind,1),real(ztes(ind)),'.-',data(ind,1),imag(ztes(ind)),'.-r'),hold on

    xlabel('Freq(Hz)(Z)');title('Real (blue) and Imaginary (red) parts of Ztes with fits (black)');
    ztes=ztes(ind);
    ztes={ztes};
    file={file};
end
grid on
