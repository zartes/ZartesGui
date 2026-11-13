function plotDiffIVs(IVset)
%%%
figure('windowstyle','docked')
allN=[];
allS=[]
subplot(3,1,1)
for i=1:length(IVset)
    plot(IVset(i).ibias(2:end),diff(IVset(i).vout)./diff(IVset(i).ibias),'.')
    hold on
    allN=[allN ;diff(IVset(i).vout(2:20))./diff(IVset(i).ibias(2:20))];
    allS=[allS ;diff(IVset(i).vout(end-20:end))./diff(IVset(i).ibias(end-20:end))];
end
subplot(3,1,2)
hist(allN,200)
subplot(3,1,3)
hist(allS,20000)
xlim([20000 25000])