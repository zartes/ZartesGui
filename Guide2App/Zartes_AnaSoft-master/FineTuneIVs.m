function [IVcorrected,IVNcorrected]=FineTuneIVs(IVraw,IVrawN,mS)
%%% funcion para tratar un centrado fino de las IVs.
%%% hay que calcular antes una buena estimación de la mS. El SplitIV da ya
%%% las mS y se puede pintar para ver el mejor valor.
%%% La pruebo con RUN002 del 2Z4_25x25 que tiene 31 IVs y funciona muy bien
%%% De las IV(27) en adelante hay que asignar toda la curva a la
%%% transicion.

%%%quitamos offset vertical de cada IV
ivzero=IVraw;ivzeroN=IVrawN;
for i=1:length(IVraw) ivzero(i).vout=IVraw(i).vout-IVraw(i).vout(end);end
for i=1:length(IVraw) ivzeroN(i).vout=IVrawN(i).vout-IVrawN(i).vout(end);end

%%%partimos las IVs en parte superconductora y transicion
ivx=SplitIV(ivzero);
ivxN=SplitIV(ivzeroN);
c.mS=mS;

rangoI=[-10:0.01:10]*1e-7;%%%rango en que buscar el ioffset
N=5;

%%%
for i=1:length(ivx)
    %if isempty(ivx(i).transicion.ibias)
     %   ivtr(i).ibias=ivzero(i).ibias;
     %   ivtr(i).vout=ivzero(i).vout;
     %   ivtrN(i).ibias=ivzeroN(i).ibias;
     %   ivtrN(i).vout=ivzeroN(i).vout;
    %else
        ivtr(i)=ivx(i).transicion; %%%ivx.transicion ya no es vacia. En Split, si da vacia se pasa la curva entera.
        ivtrN(i)=ivxN(i).transicion;
    %end
    %rang2=N:length(ivtr(i).ibias)-N;%%%definimos un rango para comparar IVs
    rang2=1:length(ivtr(i).ibias);
    for jj=1:length(rangoI)
        c.ioffset=rangoI(jj);
        ivNoff=ApplyOffset(ivtrN(i),c);
        ivNspline=spline(-ivNoff.ibias,-ivNoff.vout,ivtr(i).ibias(rang2));
        ivdiff(jj)=sum((ivtr(i).vout(rang2)-ivNspline).^2);
    end
    ioff=rangoI(find(ivdiff==min(ivdiff)))/2;%%%Hay que desplazar IVN 2*offset para hacerla coincidir con IVP.
    c.ioffset=ioff(1);
    IVcorrected(i)=ApplyOffset(ivzero(i),c);
    %IVcorrected(i).ioffset=ioff;
    IVNcorrected(i)=ApplyOffset(ivzeroN(i),c);
    %IVNcorrected(i).ioffset=ioff;
end

