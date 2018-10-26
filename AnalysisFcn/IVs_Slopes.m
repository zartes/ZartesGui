function [mN, mS] = IVs_Slopes(IVset,fig)

% Nos basamos en las diferencias de la derivada de la curva.
if nargin == 1        
    fig = figure;
end
ax(1) = subplot(1,2,1);
hold(ax(1),'on');
grid(ax(1),'on');
ax(2) = subplot(1,2,2);
hold(ax(2),'on');
grid(ax(2),'on');

tolerance = 5;

for i = 1:length(IVset)
    
    ibias = IVset(i).ibias;
    vout = IVset(i).vout;
    
    Derv = diff(vout)./diff(ibias);
    Dervx = ibias(2:end);
    
    Diffs = diff(Derv);
    Diffsx = ibias(3:end);
    ind = find(abs(Diffs) <= tolerance);
    
    Derivada{i} = Derv(ind);
    Derivadax{i} = Dervx(ind);
    
    ind_erase = find(Derv(ind) <= 0);
    Derivada{i}(ind_erase) = [];
    ind(ind_erase) = [];
    
    %     Thrs = (max(Derivada{i})-min(Derivada{i}))/2;
    %     indmN = find(Derivada{i} <= Thrs);
    %     P_mN{i} = polyfit([0; ibias(indmN)],[0; vout(indmN)],1);
    %     if P_mN{i} == 0
    %         pause;
    %     end
    %
    %     indmS = find(Derivada{i} >= Thrs);
    %     if length(indmS) == 1
    %         P_mS{i} = polyfit([0 ibias(indmS)],[0 vout(indmS)],1);
    %     else
    %         P_mS{i} = polyfit(ibias(indmS),vout(indmS),1);
    %     end
    if nargin == 2
        plot(ax(1),ibias*1e6,vout)
        plot(ax(1),ibias(ind+1)*1e6,vout(ind+1),'.r')        
           
        xlabel(ax(1),'I_{bias} (\muA)','fontsize',11,'fontweight','bold');
        ylabel(ax(1),'Vout (V)','fontsize',11,'fontweight','bold');
        set(ax(1),'fontsize',11,'fontweight','bold');  
    end
end

Pendientes = cell2mat(Derivada');
MaxP = max(Pendientes);
MinP = min(Pendientes);
Thres = (MaxP-MinP)/2;

mNvalues = Pendientes(Pendientes < Thres);
mSvalues = Pendientes(Pendientes > Thres);

Values = nan(max(length(mNvalues),length(mSvalues)),2);
Values(1:length(mNvalues),1) = mNvalues;
Values(1:length(mSvalues),2) = mSvalues;
if nargin == 2
    boxplot(ax(2),Values);    
    set(ax(2),'XTick',[1 2],'XTickLabel',{'Normal';'SuperC'})
    ylabel(ax(2),'Slopes (V/\muA)','fontsize',11,'fontweight','bold');
    set(ax(2),'fontsize',11,'fontweight','bold');
end

mN = median(Pendientes(Pendientes < Thres));
mS = median(Pendientes(Pendientes > Thres));
