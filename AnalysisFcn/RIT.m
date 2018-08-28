function [rz,Ites,Ttes]=RIT(IVset)
%funcion para deducir la corriente y temperatura en un TES a partir de los
%datos de IV medidos (Ibias vs Vout) y Tbath.

rsh = 5e-3;
%rp=1.8e-3;%
ibs = 120e-6;
vouts = 1.64;
f = 1.4e4;%maria %zgz(33.75*1e4/22);
rp = rsh*(f*ibs/vouts-1);%
n = 3.43;
K = 4.776e-8;%%
for i = 1:size(IVset,2)
    rz{i} = f*rsh*IVset(i).ibias./IVset(i).vout-rsh-rp;
    %rz=Vo;
    Ites{i} = IVset(i).vout/f;
    %Ites=1e-5;
    Ttes{i} = (Ites{i}.^2.*rz{i}/K+IVset(i).Tbath.^n).^(1/n);
end
%tri=delaunay(Ites,Ttes);
%trimesh(tri,Ites,Ttes,rz);