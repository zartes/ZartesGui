function [Nbin, eVres] = BinsEffect_FD(FilteredKData)
% load("C:\Users\Athena\Documents\Carlos Software\DatosPulsos\PulseOP.mat")
% 
% 
% nbins = 50:5:500;
% KData = PulseOP.OFT_Energy;
% DC = PulseOP.dc;
% figure,plot(KData,'.')
% KData = KData(indKa);
% DC = DC(indKa);
% KMean = nanmedian(KData);
% IQKData = 3*iqr(KData);
% FilteredKData = KData;
% Indxout = (FilteredKData >  KMean+IQKData)|(FilteredKData <  KMean-IQKData);
% FilteredKData(Indxout) = [];
% DC(Indxout) = [];
% figure,plot(KData,'.'),hold on,plot(FilteredKData,'r.')
% 
% KFMedian = median(FilteredKData);

nbins = 50:5:500;
Ka1=5887.65;%maximo Ka1.
Ka2=5898.4;%maximo Ka2.
p0=[100 5];
MnKaHandle=BuildMnKaHandle;   
% options.TolFun = 1e-9;
options = optimoptions('lsqcurvefit', 'MaxFunctionEvaluations', 200, 'MaxIterations', 500);

Nbin = [];
eVres = [];
Res = [];
j = 1;
% for i = nbins
%     Nbins = i;
    % try
    %     % [h,x] = hist(FilteredKData,Nbins);
    %     h = histogram(FilteredKData, 'BinMethod', 'fd');
    %     % 
    %     x = h.Values';
    %     h = double(movmean(h.BinEdges,2));
    %     h = h(2:end);
    % 
    %     f = fit(x(:),h(:),'gauss2');
    %     Ka_cal = polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
    %     EData = polyval(Ka_cal,FilteredKData);
    % 
    %     h = histogram(EData, 'BinMethod', 'fd');
    %     x = h.Values';
    %     h = double(movmean(h.BinEdges,2));
    %     h = h(2:end);
    %     % f = fit(x(:),h(:),'gauss2');
    %     % figure,plot(f,x,h)
    % 
    %     % Estimación de resolucion
    %     [p, resnorm, residual, ~, ~, ~, jacobian] = lsqcurvefit(MnKaHandle,p0,x(:)',h(:)');
    %     ci = nlparci(p, residual, 'jacobian', jacobian);
    %     error_p = (ci(:,2) - ci(:,1)) / 2;
    %     Res(j) = p(2);
    %     Error_Res(j) = error_p(2);
    %     Nbin = length(h);
    % catch
    % end
    % j = j+1;
% end

% Res(Res <=1) = NaN;
% [M, I] = min(Res);
% Nbin = nbins(I);

h = histogram(FilteredKData, 'BinMethod', 'fd');
Nbin = length(h.Values);

[h,x] = hist(FilteredKData, Nbin);
h = double(h);
x = double(x);
f = fit(x(:),h(:),'gauss2');        
Ka_cal = polyfit([0 f.b2 f.b1],[0 Ka1 Ka2],2);
EData = polyval(Ka_cal,FilteredKData);

h = hist(EData, Nbin);
h = double(h);
x = double(x);
[p, resnorm, residual, ~, ~, ~, jacobian] = lsqcurvefit(MnKaHandle,p0,x(:)',h(:)');
% 2. Calcular el intervalo de confianza al 95% (por defecto)
ci = nlparci(p, residual, 'jacobian', jacobian);
% 3. Error absoluto (±) de cada parámetro
error_p = (ci(:,2) - ci(:,1)) / 2;
eVres = p(2);

figure
hist(EData,Nbin);       
grid on
hold
E=5875:0.1:5910;%poster Emanuele 5870:5915;
plot(E,MnKaHandle(p,E),'r','linewidth',3)
xlim([5875 5910]);
set(gca,'fontsize',15)
xlabel('E(eV)')
title(['Nbins ' num2str(Nbin) ', Ndata ' num2str(length(FilteredKData))])
str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),'±',sprintf('%0.2f',error_p(2)),' eV');
legend({'K_\alpha data' str},'Location','northwest')


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