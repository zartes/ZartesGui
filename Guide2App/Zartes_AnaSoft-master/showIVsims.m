function showIVsims(Ttes,Ites,Tb,Ib,TESparam,Circuitparam)

Rsh=Circuitparam.Rsh;Rpar=Circuitparam.Rpar;Rn=TESparam.Rn;
Ic=TESparam.Ic;Tc=TESparam.Tc;

ites=Ites/Ic;
ttes=Ttes/Tc;
%Vtes=Ib*Rsh-Ites*(Rsh+Rpar);
rtes=FtesTI(ttes,ites);
Rtes=rtes*Rn;
Vtes=Ites.*Rtes;
Ptes=Ites.*Vtes;

%subplot(1,2,1) 
%
%%%Empiezo a usar Circuitparam como estructura con los parametros del
%%%circuito y del squid.
Rf=Circuitparam.Rf;
invMf=Circuitparam.invMf;
invMin=Circuitparam.invMin;
%Rf=1e3;%ojo, este parametro puede cambiar.
Mq=invMf/invMin;%cociente de inductancias mutuas 66/22.

Vout=Ites*Rf*Mq;%

subplot(2,4,1);plot(Ib,Vout,'.-'),grid on,hold on
xlabel('Ibias(A)');ylabel('Vout(V)');
subplot(2,4,5);plot(Vtes,Ites,'.-'),grid on,hold on
xlabel('Vtes(V)');ylabel('Ites(A)');
subplot(2,4,2);plot(Vtes,Ptes,'.-'),grid on,hold on
xlabel('Vtes(V)');ylabel('Ptes(W)');
subplot(2,4,6);plot(rtes,Ptes,'.-'),grid on,hold on
xlabel('Rtes(%)');ylabel('Ptes(W)');


%%%ya se ejecuta en showStability().
% step=1e-3;
% trange=[0:step:1.5];irange=[0:step:1.5];
% [X,Y]=meshgrid(trange,irange);
% TESparam=SetOP(X*Tc,Y*Ic,TESparam);
% stab=StabilityCheck(TESparam);

%%%pintamos contornos y estabilidad.
subplot(1,2,2)
% %contourf(X,Y,FtesTI(X,Y));
% contourf(X*Tc,Y*Ic,TESparam.R0/Rn);
% hold on
% colormap gray
% colormap(flipud(colormap))
% alpha(0.1)
% %contourf(Trange,Irange,~stab.stab);
% contourf(X*Tc,Y*Ic,~stab.stab);
% colormap cool
showStability(TESparam,Circuitparam)

%%%pintamos curvas IV y pendientes 'N' y 'S'
%plot3(ttes,ites,rtes,'.r','markersize',15)
%hold on%
plot3(Ttes,Ites,rtes,'.-k','markersize',15)
%Tb=min(Ttes);%ojo, Ttes(1) no vale para barrido en bajada.
%Tb=Ttes(Ites==0);
plotNSslopes(Tb,TESparam,Circuitparam)
%hold off

% figure(5)
% plot(Ttes,Rtes,'.-')

