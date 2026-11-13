function [OFTs,varargout]=BuildAutomaticOFTs(Pdata,varargin)
%%%funcion de analisis para sacar OFT automatico a partir del primer 
%%%analisis de datos
if nargin==1
    if ~isfield(Pdata,'filename')
        error('Faltan file names');
    end
    for i=1:length(Pdata) files(i,:)=Pdata(i).filename;end
elseif nargin==2
    files=varargin{1};
end
options=fitoptions('gauss3');
options.StartPoint=[100 0.004 1e-4 200 0.39 0.01 50 0.41 0.01];
options.Lower=zeros(1,9);

verbose=0;%%%%%
if verbose
    f1=figure('name','histo')
    f2=figure('name','ruidos')
    f3=figure('name','pulsos')
end
for i=1:length(Pdata)
    [h,x]=hist(Pdata(i).amp,1e4);%amp
    [~,pos]=findpeaks(h,'MinPeakHeight',10,'MinPeakDistance',100);
    options.StartPoint=[100 x(pos(1)) 1e-4 200 x(pos(2)) 0.01 50 x(pos(3)) 0.01];
    fg{i}=fit(x(:),h(:),'gauss3',options);
    if verbose
        figure(f1)
        subplot(1,length(Pdata),i)
        hist(Pdata(i).amp,1e4),hold on
        plot(x,fg{i}(x),'r')
    end
    if isfield(Pdata(i),'Nbaselines')
        Nbaselines=Pdata(i).Nbaselines;
    else
        Nbaselines=1000;
    end
    indNoise=find((Pdata(i).amp(1:Nbaselines)>fg{i}.b1-2.5*fg{i}.c1) & (Pdata(i).amp(1:Nbaselines)<fg{i}.b1+2.5*fg{i}.c1));
    indaux1=find(Pdata(i).rango(1:Nbaselines)-Pdata(i).amp(1:Nbaselines)<1e-3);%filtrado de artefactos negativos.
    indNoise=intersect(indNoise,indaux1);
    MeanNoise=BuildMeanPSDfromFITS(files(i,:),indNoise);
    
    indKa=find((Pdata(i).amp(:)>fg{i}.b2-2.5*fg{i}.c2) & (Pdata(i).amp(:)<fg{i}.b2+2.5*fg{i}.c2));
    indaux2=find(Pdata(i).rango(:)-Pdata(i).amp(:)<1e-3);%filtrado de artefactos negativos.
    indKa=intersect(indKa,indaux2);
    indx2=find(Pdata(i).tmax<0.0025 & Pdata(i).tmax>0.0015);%%%use robust!
    indKa=intersect(indKa,indx2);
    MeanPulse=BuildMeanPulsefromFITS(files(i,:),indKa);
    if verbose
        figure(f2)
        subplot(1,length(Pdata),i)
        loglog(MeanNoise(:,1),MeanNoise(:,2),'.-')
        %plot(Pdata(i).timestamp(indNoise),Pdata(i).amp(indNoise),'.')           
        figure(f3)
        subplot(1,length(Pdata),i)
        plot(MeanPulse(:,1),MeanPulse(:,2),'.-')
    end
    oft=BuildOptimalFilter(MeanPulse,MeanNoise);
    OFTs{i}=oft;
    varargout{1}(i).NoiseIndex=indNoise;
    varargout{1}(i).KaIndex=indKa;
    i
end