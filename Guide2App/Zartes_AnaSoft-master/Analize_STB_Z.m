function p=Analize_STB_Z(fS,ztes)
%%%Función para tratar de extraer estimates de los parámetros de ajuste de
%%%la ZTES a partir del significado de esos parámetros en el STB model.
%%%taueff=1/wmin; Zinf=-Z0/(w0*taueff)^2.
imz=imag(ztes);
rz=real(ztes);

Z0=rz(1);

[im,fm]=min(imz);
taueff=1/(2*pi*fS(fm));

if Z0<0 
    f0=spline(rz,fS,0);
    Zinf=-Z0/(taueff*2*pi*f0)^2;
else
    Zinf=rz(end);
end


% p.Z0=Z0;
% p.Zinf=Zinf;
% p.taueff=taueff;
p=[Zinf Z0 taueff];
