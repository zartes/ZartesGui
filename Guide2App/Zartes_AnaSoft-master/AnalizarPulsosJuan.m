% Script para analizar pulsos
clear all
% Cargamos el fichero de pulsos y obtenemos los parámetros de amplitud, dc
namefile = 'Pulsos_*.fits';
namedir = pwd;
[namefile,namedir] = uigetfile('*.fits','Select Pulse FIT file',namedir);
filename = [namedir namefile];
addpath('.\HandleLibrary\')
addpath('.\utils\')
addpath('.\utils\jsonlab-2.0\')

Ka1 = 5887.65;%maximo Ka1.
Ka2 = 5898.4;%maximo Ka2.

IbiasPerc = str2double(namefile(max(strfind(namefile,'_'))+1:max(strfind(namefile,'.'))-1));

f = waitbar(0,'Analyzing Pulse Data, Please wait...');

tic;
PulseParameters = AnalizaPulseFITS(filename);
display(toc);
if ishandle(f)
    waitbar(0.1,f,'Building Mean Noise, Please wait...');
end

% Se obtienen los parámetros medios para generar el filtro óptimo

% Ajuste a una gaussiana de tres picos, ruido, kalpha y kbeta
options=fitoptions('gauss3');
options.StartPoint=[100 0.004 1e-4 200 0.39 0.01 50 0.41 0.01];
options.Lower=zeros(1,9);

try 
    
    [h,x]=hist(PulseParameters.amp,1e4);
    h = double(h);
    x = double(x);
    [~,pos] = findpeaks(h,'MinPeakHeight',10,'MinPeakDistance',100);
    options.StartPoint=[100 x(pos(1)) 1e-4 200 x(pos(2)) 0.01 50 x(pos(3)) 0.01];
    options.TolFun = 1e-9;
catch
    KMean = median(PulseParameters.amp);
    IQKData = 3*iqr(PulseParameters.amp);
    FilterData = PulseParameters.amp;
    Indxout = (FilterData >  KMean+IQKData)|(FilterData <  KMean-IQKData);
    FilterData(Indxout) = [];
    [h,x]=hist(FilterData,1e4);
    [~,pos] = findpeaks(h,'MinPeakHeight',10,'MinPeakDistance',100);
    options.StartPoint=[100 x(pos(1)) 1e-4 200 x(pos(2)) 0.01 50 x(pos(3)) 0.01];
end

fg = fit(x(:),h(:),'gauss3',options);
indNoise=find((PulseParameters.amp>fg.b1-2.5*fg.c1) & (PulseParameters.amp<fg.b1+2.5*fg.c1));

%Primera inspección visual
% figure,plot(PulseParameters.amp,'.'),hold on, plot(indNoise,PulseParameters.amp(indNoise),'r.')


MeanNoise=buildMeanPSDfromFITS(filename,indNoise);

if ishandle(f)
    waitbar(0.2,f,'Building Mean Pulse, Please wait...');
end
indKa=find((PulseParameters.amp>fg.b2-2.5*fg.c2) & (PulseParameters.amp<fg.b2+2.5*fg.c2));
% figure,plot(indKa,PulseParameters.amp(indKa),'m.')
% Tomamos solo aquellos pulsos que tengan el mismo dc,
% preguntar al usuario cuantos saltos hay
% dc = PulseParameters.dc(indKa);
% idx = kmeans(dc',2);
% indKaB = indKa(idx == 1);
% indKaGood = indKa(idx == 2);
% figure,plot(PulseParameters.dc,'.'), hold on, plot(indKa,PulseParameters.dc(indKa),'.r')
% 
% xlabel('Pulses')
% ylabel('DC')
% drawnow
% pause(0.1);
% Pedir al usuario que elija el segmento que va a utilizar para crear el
% filtro óptimo.
% rect = getrect(); 
% limites_x = [rect(1), rect(1) + rect(3)];
% disp(['Límites en X seleccionados: ', num2str(limites_x)]);
% limites = round(limites_x);
% indKaGood = limites(1):1:limites(2);
% hold on, plot(indKaB,PulseParameters.dc(indKaB),'.g')

% Buscaremos aquellos pulsos que no tengan pilelaps
indKaGood = [];
j = 1;
for i = indKa    
    [pks,locs] = findpeaks(100+PulseParameters.pulso2(i,:),'MinPeakHeight',min(100+PulseParameters.pulso2(i,:)+0.5*range(100+PulseParameters.pulso2(i,:))));
    if length(pks) == 1
        % i
        indKaGood(j) = i;
        j = j+1;
    end
    if ishandle(f)
        waitbar(i/length(indKa),f,'Building Mean Pulse, Please wait...');
    end
end
indKaPileLaps = setdiff(indKa,indKaGood);
MeanPulse=buildMeanPulsefromFITS(filename,indKaGood);

% MeanPulse=buildMeanPulsefromFITS(filename,indKaGood);
if ishandle(f)
    waitbar(0.4,f,'Building Optimal Filter, Please wait...');
end
oft=buildOptimalFilter(MeanPulse,MeanNoise);
OP.oft = oft;


% MeanPulse=buildMeanPulsefromFITS(filename,indKa);
% oft=buildOptimalFilter(MeanPulse,MeanNoise);
% OP.oft = oft;


% Se analizan los pulsos con el filtro óptimo para calcular la energía
if ishandle(f)
    waitbar(0.5,f,'Analyzing Pulse Data with Optimal Filter, Please wait...');
end
tic;
PulseOP = AnalizaPulseFITS(filename,OP);
display(toc);

KData = PulseOP.OFT_Energy;
DC = PulseOP.dc;
KData = KData(indKa);
DC = DC(indKa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aplicamos un primer filtro para quitar outliers
% El usuario deberá decidir cuanto margen aplica
KMean = median(KData);
IQKData = 3*iqr(KData);
FilteredKData = KData;
Indxout = find(FilteredKData >  KMean+IQKData|FilteredKData <  KMean-IQKData);


true = 1;
IQR_Factor = 3;
while true 
    answer = 'Yes';
    % answer = questdlg(['Remove outliers greater than ' num2str(IQR_Factor)],'');
    switch answer
        case 'Yes'
            IQKData = IQR_Factor*iqr(KData);
            Indxout = find(FilteredKData >  KMean+IQKData|FilteredKData <  KMean-IQKData);
            % figure,plot(KData,'.')
            % hold on, plot(Indxout,KData(Indxout),'.r')
            % plot(ones(1,length(KData)).*(KMean+IQKData))
            % plot(ones(1,length(KData)).*(KMean-IQKData))
            % answer = questdlg('Are you sure, or you want to change IQR factor?','','Yes, I am sure','No, I want to change','Yes, I am sure');
            answer = 'Yes, I am sure';
            switch answer               

                case 'No, I want to change'
                    answer = inputdlg('Please, select the new IQR factor','');
                    IQR_Factor = str2double(answer);
                    IQKData = IQR_Factor*iqr(KData);
                    Indxout = find(FilteredKData >  KMean+IQKData|FilteredKData <  KMean-IQKData);
                    figure,plot(KData,'.')
                    hold on, plot(Indxout,KData(Indxout),'.r')
                    plot(ones(1,length(KData)).*(KMean+IQKData))
                    plot(ones(1,length(KData)).*(KMean-IQKData))
                    answer1 = questdlg('Are you sure, or you want to change IQR factor?','','Yes, I am sure','No, I want to change','Yes, I am sure');
                    switch answer1
                        case 'No, I want to change'
                            answer = inputdlg('Please, select the new IQR factor','');
                            IQR_Factor = str2double(answer);
                            IQKData = IQR_Factor*iqr(KData);
                            Indxout = find(FilteredKData >  KMean+IQKData|FilteredKData <  KMean-IQKData);
                            figure,plot(KData,'.')
                            hold on, plot(Indxout,KData(Indxout),'.r')
                            plot(ones(1,length(KData)).*(KMean+IQKData))
                            plot(ones(1,length(KData)).*(KMean-IQKData))
                            FilteredKData(Indxout) = [];
                            DC(Indxout) = [];
                            true = 0;

                        otherwise
                            FilteredKData(Indxout) = [];
                            DC(Indxout) = [];
                            true = 0;
                    end

                otherwise
                    FilteredKData(Indxout) = [];
                    DC(Indxout) = [];
                    true = 0;

            end

        otherwise

    end
end

% ,hold on, plot(Indxout,KData(Indxout),'.r')
% plot(ones(1,length(KData)).*(KMean+IQKData))
% plot(ones(1,length(KData)).*(KMean-IQKData))

% En caso afirmativo se eliminan
% FilteredKData(Indxout) = [];
% DC(Indxout) = [];
if ishandle(f)
    waitbar(0.6,f,'Estimating number of data clusters, Please wait...');
end
eva = evalclusters(DC', 'kmeans', 'Silhouette', 'KList', 1:10);
% plot(evaluation);
NumSub = eva.OptimalK;
idx = kmeans(DC',NumSub);

% figure,plot(DC,'.')
% answer = inputdlg('Insert number of data populations','');
% try
%     NumSub = str2double(answer);
% catch
%     NumSub = 2;
% end
% % El usuario deberá decir cuántas agrupaciones hay (saltos)
% idx = kmeans(DC',NumSub);


% figure, hold on; legend('Location', 'eastoutside');
% for i = 1:NumSub
%     plot(find(idx == i),DC(idx == i),'.','DisplayName',['Subgroup: ' num2str(i)]);
% end

Data = [];
for i = 1:NumSub
    if ishandle(f)
        waitbar(min(0.6+0.1*i,1),f,['Estimating espectral resolution of cluster ' num2str(i) '/' num2str(NumSub)], 'Please wait...');
    end
    Data = FilteredKData(idx == i);
    
    KMedian = median(Data);

    answer = 'Yes';
    % answer = questdlg('Do you want to filter the data?','');
    switch answer
        case 'Yes'
            true = 1;
            % answer = inputdlg('Please, select the new IQR factor','',1,{'3'});
            IQR_Factor = 3;
            % IQR_Factor = str2double(answer);
            IQKData = IQR_Factor*iqr(Data);
            Indxout = find(Data >  KMedian+IQKData|Data <  KMedian-IQKData);
            % figure,plot(Data,'.')
            % hold on, plot(Indxout,Data(Indxout),'.r')
            % plot(ones(1,length(Data)).*(KMedian+IQKData),'r-')
            % plot(ones(1,length(Data)).*(KMedian-IQKData),'r-')
            answer1 = 'Yes';
            % answer1 = questdlg('Do you want to continue?','','Yes','No, change IQR Factor','Yes');
            switch answer1
                case 'Yes'
                    Indxout = (Data >  KMedian+IQKData)|(Data <  KMedian-IQKData);
                    Data(Indxout) = [];
                    true = 0;
                otherwise
            end
            while true      
                answer = inputdlg('Please, select the new IQR factor','',1,{'3'});
                IQR_Factor = str2double(answer);
                IQKData = IQR_Factor*iqr(Data);
                Indxout = find(Data >  KMedian+IQKData|Data <  KMedian-IQKData);
                figure,plot(Data,'.')
                hold on, plot(Indxout,Data(Indxout),'.r')
                plot(ones(1,length(Data)).*(KMedian+IQKData),'r-')
                plot(ones(1,length(Data)).*(KMedian-IQKData),'r-')
                answer1 = questdlg('Do you want to continue?','','Yes','No, change IQR Factor','Yes');
                switch answer1
                    case 'Yes'
                        Indxout = (Data >  KMedian+IQKData)|(Data <  KMedian-IQKData);
                        Data(Indxout) = [];
                        true = 0;
                    otherwise
                end                
            end
        otherwise
    end   
    [Nbin, eVres] = BinsEffect(Data);
end
if ishandle(f)
    delete(f);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% En caso de tener saltos, se agrupan los datos en función de los saltos
% Y = medfilt1(FilteredKData,50);
% Y(1) = Y(2);

% % El usuario deberá decir cuántas agrupaciones hay (saltos)
% idx = kmeans(DC',2);
% % idx = kmeans(Y',2);
% figure, plot(find(idx == 1),DC(idx == 1),'r.'),hold on, plot(find(idx == 2),DC(idx == 2),'b.')

%%%%%%%%%%%%%%%%% No se continua

% Data1 = FilteredKData(idx == 1);
% IQData1 = 3*iqr(Data1);
% KMedian1 = median(Data1);
% Indxout1 = (Data1 >  KMedian1+IQData1)|(Data1 <  KMedian1-IQData1);
% Data1(Indxout1) = [];
% 
% 
% [Nbin1, eVres] = BinsEffect(Data1);
% 
% [h,x] = hist(Data1, Nbin1);
% h = double(h);
% x = double(x);
% [f, gof, output] = fit(x(:),h(:),'gauss2');
% Ka_cal1 = polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
% EData1 = polyval(Ka_cal1, Data1);
% 
% Data2 = FilteredKData(idx==2);
% IQData2 = 3*iqr(Data2);
% KMedian2 = median(Data2);
% Indxout2 = (Data2 >  KMedian2+IQData2)|(Data2 <  KMedian2-IQData2);
% Data2(Indxout2) = [];
% 
% 
% [Nbin2, eVres2] = BinsEffect(Data2);
% 
% [h,x] = hist(Data2, Nbin2);
% h = double(h);
% x = double(x);
% f= fit(x(:),h(:),'gauss2');
% Ka_cal2 = polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
% EData2 = polyval(Ka_cal2, Data2);
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%
% % Aquí estaría la estratégia de utilizar todos los datos
% % EData = [EData1 EData2];
% % [h,x]=hist(EData,Nbin1);
% % % f= fit(x(:),h(:),'gauss2');
% % % figure,plot(f,x,h)
% % 
% % % Estimación de resolucion
% % MnKaHandle=BuildMnKaHandle;
% % p0=[100 5]; 
% % 
% % % Límites estrictos [p1_min, p2_min] y [p1_max, p2_max]
% % % Impide que el FWHM baje de cero o suba a valores absurdos
% % lb = [0.1, 0.5];  
% % ub = [max(h(:))*10, 15.0]; 
% % funObjetivoGlobal = @(p0) sum((MnKaHandle(p0, x(:)) - h(:)).^2);
% % problem = createOptimProblem('fmincon', ...
% %     'objective', funObjetivoGlobal, ...
% %     'x0', p0, ...
% %     'lb', lb, ...
% %     'ub', ub);
% % gs = GlobalSearch('Display', 'iter', 'NumTrialPoints', 500);
% % [p_global, fval] = run(gs, problem);
% % fprintf('Amplitud p(1): %.4f\n', p_global(1));
% % fprintf('Resolución FWHM p(2): %.4f\n', p_global(2));
% % 
% % options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt' ); % 'interior-point' %trust-region-reflective %levenberg-marquardt
% % [p,resnorm,residual,exitflag,output]=lsqcurvefit(MnKaHandle,p0,x(:),h(:),[],[],options);
% % 
% % 
% % figure
% % hist(EData1,Nbin1);
% % grid on
% % hold
% % E=5875:0.1:5910;%poster Emanuele 5870:5915;
% % plot(E,MnKaHandle(p,E),'r','linewidth',3)
% % xlim([5875 5910]);
% % set(gca,'fontsize',15)
% % xlabel('E(eV)')
% % str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),' eV');
% % legend({'K_\alpha data' str},'Location','northwest')
% % 
% % % DataFilt = (FilteredKData-Y)+KFMedian;
% % % FilteredKData = DataFilt;
% % % FilteredKData(1:nbins) =[];
% % % FilteredKData(end-nbins:end) = [];
% % % figure,plot(FilteredKData,'.')
% % 
% % 
% % % FilteredKData_corr = FilteredKData;
% % % Underindx = FilteredKData <= KFMedian;
% % % UnderValues = KFMedian-FilteredKData;
% % % FilteredKData_corr(Underindx) = FilteredKData(Underindx)+UnderValues(Underindx);
% % % Overindx = ~Underindx; 
% % % FilteredKData(Underindx)
% % 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Si no hay saltos
% 
% [h,x]=hist(FilteredKData,nbins);
% f= fit(x(:),h(:),'gauss2');
% Ka1=5887.65;%maximo Ka1.
% Ka2=5898.4;%maximo Ka2.
% Ka_cal=polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
% EData = polyval(Ka_cal,FilteredKData);
% 
% 
% [h,x]=hist(EData,nbins);
% f= fit(x(:),h(:),'gauss2');
% figure,plot(f,x,h)
% 
% % Estimación de resolucion
% MnKaHandle=BuildMnKaHandle;
% p0=[100 5];
% p=lsqcurvefit(MnKaHandle,p0,x(:),h(:));
% hist(EData,nbins);
% grid on
% hold
% E=5875:0.1:5910;%poster Emanuele 5870:5915;
% plot(E,MnKaHandle(p,E),'r','linewidth',3)
% xlim([5875 5910]);
% set(gca,'fontsize',15)
% xlabel('E(eV)')
% str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),' eV');
% legend({'K_\alpha data' str},'Location','northwest')



% EDataX = linspace(min(EData),max(EData),500);
% EData_Cont= polyval(f,EDataX);
% % Se calibran los resultados a energía
% figure,hist(PulseOP.OFT_Energy,1e4);
% varargout=FitKaData(PulseOP,indKa);
% options=FormatKaSpectrumWithResidues(PulseOP.OFT_Energy);
