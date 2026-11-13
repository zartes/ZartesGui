function CompareIV_Z(IVset,P,Tbath)
%%%Función para pintar conjuntamente parámetros deducidos de las IVs y de
%%%las Z(w)a una Tbath pasada en milikelvin.

    %Extraemos la IV y la P asociadas a la Tbath de interés.
    [m1,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [m2,Tind]=min(abs([P.Tbath]*1e3-Tbath));
    p=P(Tind).p;
    thr=1;%%%umbral en 1mK de diferencia entre la Tbath pasada y la Tbath más cercana de los datos.
    if (m1>=thr || m2>=thr) error('Tbath not in the measured data. \n Remember to pass Tbath as a number in mK');end
    
    xiv_min=0.05;
    xiv=0.5*([IVstr.rtes(1:end-1)]+[IVstr.rtes(2:end)]);
    indx1=find(xiv>xiv_min);
    
    a_eff=diff(log(IVstr.Rtes))./diff(log([IVstr.ttes]));
    %a_eff=diff(log(medfilt1([IVstr.Rtes],200)))./diff(log(medfilt1([IVstr.ttes],200)));
    b_eff=diff(log(IVstr.Rtes))./diff(log([IVstr.ites]));
    invb_eff=diff(log(IVstr.ites))./diff(log([IVstr.Rtes]));
    
    xz=[p.rp];
    xz_min=0.05;
    indx2=find(xz>xz_min);
    
    Za_effAprox=[p.ai]./(1+[p.bi]);
    %ecY='ai./(1+bi)';%%alfa_eff_Aprox
    
    %Za_eff=[p.ai_fixed].*(2*[p.L0]+[p.bi])./(2+[p.bi])./[p.L0];
    Za_eff=[p.ai].*(2*[p.L0]+[p.bi])./(2+[p.bi])./[p.L0];
    %ecY='ai.*(2*L0+bi)./(2+bi)./L0';%%%alfa_eff1
    
    %Zb_eff=([p.bi]+2*[p.Lh])./(1-[p.Lh]);
    Zb_eff=([p.bi]+2*[p.L0])./(1-[p.L0]);
    %ecY='(bi+2*L0)./(1-L0)';%%%beta_eff
    invZb_eff=1./Zb_eff;
    %ecY='(1-L0)./(bi+2*L0)'; %%%inverse beta_eff
    
    %%%Un poco de filtrado
    indx11=find(xiv>xiv_min & 1); %%%(xiv<0.8 & a_eff>0.5)
    indx22=find(xz>xz_min & 1); %%%(xz<0.8 & Za_eff>0.5)
    
    
    subplot(2,1,1)
    %plot(xiv(indx1),a_eff(indx1),'.-',xz(indx2),Za_eff(indx2),'.-',xz(indx2),Za_effAprox(indx2),'.-','linewidth',2,'markersize',15);
    plot(xiv(indx11),medfilt1(a_eff(indx11),15),'.-',xz(indx22),Za_eff(indx22),'.-','linewidth',2,'markersize',15);
    grid on,xlim([xiv_min 0.95]),ylim([0 250]), ylabel('\alpha_{eff}','fontsize',12,'fontweight','bold')
    xlabel('R_{TES}/R_n','fontsize',12,'fontweight','bold')
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
    %legend('IV','Z','Z_{aprox}')
    legend('IV','Z')
    
    subplot(2,1,2)
    plot(xiv(indx1),b_eff(indx1),'.-',xz(indx2),Zb_eff(indx2),'.-','linewidth',2,'markersize',15)
    grid on,xlim([xiv_min 0.95]),ylim([-5 5]),ylabel('\beta_{eff}','fontsize',12,'fontweight','bold')
    xlabel('R_{TES}/R_n','fontsize',12,'fontweight','bold')
    set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
    legend('IV','Z')
    
%     subplot(1,3,3)
%     plot(xiv(indx1),invb_eff(indx1),'.-',xz(indx2),invZb_eff(indx2),'.-','linewidth',2,'markersize',15)
%     grid on,xlim([0 1]),ylim([-1 1]),ylabel('inv\beta_{eff}','fontsize',12,'fontweight','bold')
%     xlabel('%R_n','fontsize',12,'fontweight','bold')
%     set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
%     legend('IV','Z')