function compareIVSimMeas(Tbath,IVmeas,TES,Circuitparam)


IVsim=simIV(Tbath,TES,Circuitparam);

subplot(2,4,1);plot(IVmeas.ibias,IVmeas.voutc,'.--r','DisplayName',num2str(IVmeas.Tbath)),grid on,hold on
subplot(2,4,2);plot(IVmeas.vtes,IVmeas.ptes,'.--r','DisplayName',num2str(IVmeas.Tbath)),grid on,hold on
subplot(2,4,5);plot(IVmeas.vtes,IVmeas.ites,'.--r','DisplayName',num2str(IVmeas.Tbath)),grid on,hold on
subplot(2,4,6);plot(IVmeas.rtes,IVmeas.ptes,'.--r','DisplayName',num2str(IVmeas.Tbath)),grid on,hold on

subplot(1,2,2);plot(IVmeas.ttes,IVmeas.ites,'b.-')