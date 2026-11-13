function ALL=GetPatOP(P,Tbath,varargin)
%%%%funcion para devolver estructura con todos los campos a una Tbath (en mK)
%%%%determinada y unos %Rn dados

    [m2,mP]=min(abs([P.Tbath]*1e3-Tbath));
    %p=P(mP).p;
    thr=1;%%%umbral en 1mK de diferencia entre la Tbath pasada y la Tbath más cercana de los datos.
    if (m2>=thr) error('Tbath not in the measured data. \n Remember to pass Tbath as a number in mK');end

ALL=GetAllPparam(P(mP));
names=fieldnames(ALL);
if nargin ==3, 
    perc=varargin{1};w=0.02;LB=perc-w;HB=perc+w;
    ind=find(ALL.rp>LB & ALL.rp<HB);
else
    ind=1:length(ALL.rp);
end


for i=1:length(names)-1
    %ALL.(names{i})
    %strcat('ALL.',names{i},'(ind)')
    %eval(strcat('ALL.',names{i},'(ind)'));
    ALL.(names{i})=eval(strcat('ALL.',names{i},'(ind)'));
end