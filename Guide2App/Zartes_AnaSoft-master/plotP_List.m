function plotP_List(P_List,xp,yp)
%%%Función para pintar una lista de estructuras P, que pueden ser de varios
%%%TES o del mismo TES pero distintos RUNs. Si se quiere que sea sólo una
%%%temperatura hay que seleccionarla expresamente P_List{i}=TES.P(j)
for i=1:length(P_List)
    P=P_List{i};
    plotParamTES(P,xp,yp)
end