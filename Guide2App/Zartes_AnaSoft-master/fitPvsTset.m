function Gaux=fitPvsTset(IVTESset,perc,varargin)
%funcion para ajustar automaticamente curvas P-Tbath a un valor o valores
%de porcentaje de Rn. Ojo al uso de cells o arrays en IVset.
% varargin{1}=modelo [1, 2 o 3].

if nargin==2
    %model=1; %%%old default model
    model=BuildPTbModel();%%%default model aTb^n+P0;
else
    model=varargin{1};
end

%for i=1:length(IVTESset), Tbath(i)=IVTESset(i).Tbath;end

hold off;
RTESmin=0.15;%%%ojo, perc tiene que estar incluido en este rango.
RTESmax=0.9;
for jj=1:length(perc)
    Paux=[];
    Iaux=[];
    Tbath=[];
    for i=1:length(IVTESset) 
        if isfield(IVTESset,'good') good=IVTESset(i).good;else good=1;end
            if good
%disp(IVTESset(i).Tbath)%
        %txt=strcat('P',num2str(100*perc(jj)));
        %exec=strcat(txt,'(i)=','ppval(spline(IVTESset{i}.rtes,IVTESset{i}.ptes),jj)')
        %evalin('caller',exec);
        %ind=find(IVTESset(i).rtes>0.25&IVTESset(i).rtes<0.85);%%%algunas IVs fallan.
         ind=find(IVTESset(i).rtes>RTESmin&IVTESset(i).rtes<RTESmax);%%%algunas IVs fallan.
         minIV=min(abs([IVTESset(i).rtes]));
        if isempty(ind)||minIV>perc(jj)||minIV>0.5 continue;end
        [rtaux,iii]=unique(IVTESset(i).rtes(ind));
        ptaux=IVTESset(i).ptes(ind(iii));
        itaux=IVTESset(i).ites(ind(iii));
        %Paux(end+1)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj));
        %Iaux(end+1)=ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%%%
        %Paux(end+1)=ppval(spline(rtaux,ptaux),perc(jj));
        %Iaux(end+1)=ppval(spline(rtaux,itaux),perc(jj));
        Paux(end+1)=interp1(rtaux,ptaux,perc(jj));
        Iaux(end+1)=interp1(rtaux,itaux,perc(jj));
        Tbath(end+1)=IVTESset(i).Tbath;
            end%%%if good
    end %%%for Tbath
    %fitaux=fit(Tbath',Paux'*1e12,'a*x^b+c','startpoint',[0 3 0]);
    %Tbath
    %Paux
    %Tbath=0.9932*Tbath+0.006171; %%Curva de calibración del termómetro Kelvinox al calibrado. Ver Tcal.m en medidas/TES.
    plot(Tbath,Paux*1e12,'bo','markerfacecolor','b'),hold on,grid on
    
    if isnumeric(model)%%%old model definition
    if model==1
        X0=[-50 3 1];XDATA=Tbath;LB=[-Inf 2 0 ];%%%Uncomment for model1
        
        %X0=[50 3 0.1];XDATA=Tbath;LB=[0 2 0 ];%%%Conditions for p=[K n Tc].
        %X0=[65 9500 0.09]; %%%[A, B, Tc] en modelo a T^2+T^4
    elseif model==2
        %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0.
        %X0=[-5000 3.0 10 1e4 0]; XDATA=[Tbath;Iaux*1e6];LB=[-1e5 2 0 0 0];%%%Uncoment for model2
        X0=[-6500 3.03 13 1.9e4]; XDATA=[Tbath;Iaux*1e6];LB=[-1e5 2 0 0];
    elseif model==3
        %%%intento ajuste Gb
        auxtbath=min(Tbath):1e-4:max(Tbath);
        %auxptes=spline(Tbath,Paux,auxtbath);
        auxptes=interp1(Tbath,Paux,auxtbath);
        gbaux=abs(diff(auxptes)./diff(auxtbath));
        fit2=lsqcurvefit(@(x,tbath)x(1)+x(2)*tbath,[3 2], log(auxtbath(2:end)),log(gbaux));
        Gaux(jj).n=(fit2(2)+1);
        Gaux(jj).K=exp(fit2(1))/Gaux(jj).n;
        figure(3),plot(log(auxtbath(2:end)),log(gbaux),'.-')
    end   
    if model~=3
        %model=1;
        fitfun=@(x,y)fitP(x,y,model);
        [fit,~,aux2,~,~,~,auxJ]=lsqcurvefit(fitfun,X0,XDATA,Paux*1e12,LB);
        %[fit,~,aux2,~,~,~,auxJ]=lsqcurvefit(@fitP,X0,XDATA,Paux*1e12,LB);
        ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
        plot(Tbath,fitP(fit,XDATA,model),'-r','linewidth',1)
        Gaux(jj)=GetGfromFit(fit);%%antes se pasaba fitaux.
        auxxx(jj).ci=ci;
    end
    
    elseif isstruct(model)
        X0=model.X0;
        LB=model.LB;
        XDATA=Tbath;if strcmp(model.nombre,'Ic0') XDATA=[Tbath;Iaux*1e6];end
        fitfun=@(x,y)fitP(x,y,model);
        [fit,~,aux2,~,~,~,auxJ]=lsqcurvefit(fitfun,X0,XDATA,Paux*1e12,LB);
        ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
        plot(Tbath,fitP(fit,XDATA,model),'-r','linewidth',1)
        model.ci=ci;
        Gaux(jj)=GetGfromFit(fit,model);%%antes se pasaba fitaux.
        auxxx(jj).ci=ci;
        for ii=1:length(ci) auxxx(jj).err(ii)=ci(ii,2)-ci(ii,1);end
    end 
end
for jj=1:length(perc) 
    Gaux(jj).rp=perc(jj);
    Gaux(jj).ci=auxxx(jj).ci;
    Gaux(jj).model=model;
end


xlabel('T_{bath}(K)','fontsize',11,'fontweight','bold')
ylabel('P_{TES}(pW)','fontsize',11,'fontweight','bold')
%title('P vs T fits','fontsize',11,'fontweight','bold')
set(gca,'fontsize',12,'linewidth',2,'fontweight','bold')



