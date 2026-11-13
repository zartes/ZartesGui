function plotZ_Tb_Rp(anaStruct,Rp,Temp,varargin)
%%%% funcion para pintar la Z(w) y los fits a un porcentaje a partir de una
%%%% estructura. ej: Rp=[0.2:0.05:0.8]. Temp=50 (temperatura en mK).

olddir=pwd;

%%%Cargamos la estructura colores para los plots.
%colordir='C:\Users\Carlos\Desktop\ATHENA\medidas';
%colordir='C:\Users\Athena\Documents\GitHub\zartes\utils';
colordir='\\qmadnas\zartes\DOCUZAR\Datos';
cd(colordir);
%cd2CloudDataDir(GetCloudDataDir());
load('colores.mat')%%%esto carga la estructura colores.
cd(olddir)

datadir=anaStruct.analizeOptions.datadir;
cd(datadir);
%cd2CloudDataDir(datadir);
 
[mIV,mP]=GetTbathIndex(Temp,anaStruct);%%%Se asume que para todas las temperaturas se toman tanto datos positivos como negativos.

%%%podemos pasar polaridad e indice en cualquier orden.
polstr='p';
f_index=1:length(anaStruct.TFS.f);
for i=1:length(varargin)
    if ischar(varargin{i}) polstr=varargin{i};end
    if isnumeric(varargin{i}) f_index=varargin{i};end
end

Zdata_string=anaStruct.analizeOptions.ZfitOpt.TFdata;
if strcmp(Zdata_string,'HP')
    TF_str='\TF_*';
elseif strcmp(Zdata_string,'PXI')
    TF_str='\PXI_TF_*';
end
%polarity=1;%%%1:P,0:N.
if strcmpi(polstr,'p')
    polarity=1;
else
    polarity=0;
end
if polarity
    fileList=GetFilesFromRp(anaStruct.IVset(mIV),Temp,Rp,TF_str)
    color=colores.azul;
    %color=colores.naranja;
else
    cd('Negative Bias')
    fileList=GetFilesFromRp(anaStruct.IVsetN(mIV),Temp,Rp,TF_str)
    color=colores.naranja;
end

Tdir=GetDirfromTbath(Temp);
strcat(Tdir,'\',fileList)

tfList=importTF(strcat(Tdir,'\',fileList));

figZs=findobj('name','Zfig');
figImRe=findobj('name','ImRefig');
if ~isempty(figZs) hZ=figZs.Number; else figZs=figure('name','Zfig');hZ=figZs.Number; end
if ~isempty(figImRe) hImRe=figImRe.Number; else figImRe=figure('name','ImRefig');hImRe=figImRe.Number; end

for i=1:length(tfList)
      zList{i}=GetZfromTF(tfList{i},anaStruct.TFS,anaStruct.circuit);
      figure(hZ)
      plot(zList{i}.tf(f_index),'.-','color',color),hold on
      %plot(zList{i}.tf(625),'o','linewidth',5);%%% pintamos el punto en que f=2e3.(indice 529).<-serie 2Z4? f=8e3 (625)1Z2.
      figure(hImRe)
      freqs=zList{i}.f(f_index);
      semilogx(freqs,imag(zList{i}.tf(f_index)),'.-'),hold on
      semilogx(freqs,real(zList{i}.tf(f_index)),'.-'),hold on
end

% if length(anaStruct.P(mP).p(1).parray)==3
%     px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' GetPparam(anaStruct.P(mP).p,'taueff')' ];
% else
%     px=[GetPparam(anaStruct.P(mP).p,'Zinf')' GetPparam(anaStruct.P(mP).p,'Z0')' ...
%     GetPparam(anaStruct.P(mP).p,'taueff')' GetPparam(anaStruct.P(mP).p,'geff')' GetPparam(anaStruct.P(mP).p,'t_1')' ];
% end

if polarity
    for ii=1:length([anaStruct.P(mP).p.rp]) px(ii,:)=anaStruct.P(mP).p(ii).parray; end
else
    for ii=1:length([anaStruct.PN(mP).p.rp]) px(ii,:)=anaStruct.PN(mP).p(ii).parray; end
end

m_name=anaStruct.analizeOptions.ZfitOpt.ThermalModel;
model=BuildThermalModel(m_name);
func=model.function

%%%1TB model
model1TB=BuildThermalModel('default');
Z1TB=model1TB.Cfunction;
%%%
%%%Pintamos el modelo
for i=1:length(Rp)
    if polarity
        [~,jj]=min(abs([anaStruct.P(mP).p.rp]-Rp(i)));
    else
        [~,jj]=min(abs([anaStruct.PN(mP).p.rp]-Rp(i)));
    end
    %%%
    p1tb=px(jj,[1:3]);p1tb(3)=-sign(p1tb(2))*abs(p1tb(3));
    z1tbx=Z1TB(p1tb,anaStruct.TFS.f);
    %zx=fitZ(px(jj,:),anaStruct.TFS.f);
    zx=func(px(jj,:),anaStruct.TFS.f);
    figure(hZ)
    plot(zx(:,1),zx(:,2),'-r');grid on
    if(1)% si quiero pintar también el modelo 1TB.
    plot(z1tbx,'--k');
    end
    figure(hImRe)
    semilogx(anaStruct.TFS.f,zx(:,2),'-r');
    semilogx(anaStruct.TFS.f,zx(:,1),'-k');
    grid on
    figure(hZ)
end

cd(olddir)