function CheckTF(circuit)
tfn=TF_HP(circuit.Rn,circuit);
tfs=TF_HP(0,circuit);

xN=tfn.re;yN=tfn.im;
xS=tfs.re;yS=tfs.im;
f=tfn.f;

%plot(tfn.tf,'k','linewidth',2)
%plot(tfs.tf,'m','linewidth',2)
%patch(X,Y,C,opt)
patch([xN nan],[yN nan],[log10(f) nan],'edgecolor','interp','linewidth',2);
patch([xS nan],[yS nan],[log10(f) nan],'edgecolor','interp','linewidth',2);
colorbar;grid on