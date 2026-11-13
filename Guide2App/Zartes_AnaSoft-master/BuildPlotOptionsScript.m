function opt=BuildPlotOptionsScript()
%%%podemos ir creando diferentes estilos y llamar a la funci√≥n con el
%%%estilo que necesitemos en cada llamada.

%%%list of propertiy names:
%names={'Color' 'LineStyle' 'LineWidth' 'Marker' 'MarkerSize' 'MarkerEdgeColor' 'MarkerFaceColor'};
lineColors = {[0,0,1];[1,0,0];[0,0.5,0];[0,0,0];[1,0,1];[0,1,1];[0.5 0.5 0.5];[1,1,0]};

style='IVsZTES13';%'IVsZTES20'(16 lines);%'3param';%'IVsZTES13'(15 lines);%'8transitionswithfit';
if strcmp(style,'8transitionswithfit')
    
    lineWidthArray([1:16],1)={2};
    lineColorArray([1 3],1)=lineColors(1);
    lineColorArray([2 4],1)=lineColors(2);
    lineColorArray([5 7],1)=lineColors(3);
    lineColorArray([6 8],1)=lineColors(4);
    lineColorArray([9 11],1)=lineColors(5);
    lineColorArray([10 12],1)=lineColors(6);
    lineColorArray([13 15],1)=lineColors(7);
    lineColorArray([14 16],1)=lineColors(8);
    lineStyleArray([1 2 5 6 9 10 13 14],1)={'none'};
    lineStyleArray([3 4 7 8 11 12 15 16],1)={'-'};
    
    MarkerArray([1 2 5 6 9 10 13 14],1)={'.'};
    MarkerArray([3 4 7 8 11 12 15 16],1)={'none'};
    MarkerSizeArray([1:16],1)={15};
    MarkerEdgeColorArray={};
    MarkerFaceColorArray={};
    
    displaynameArray([1 2 5 6 9 10 13 14],1)={'R1';'R2';'L1';'L2';'R3';'R4';'L3';'L4'};
    displaynameArray([3 4 7 8 11 12 15 16],1)={'fitR1';'fitR2';'fitL1';'fitL2';'fitR3';'fitR4';'fitL3';'fitL4'};
    
    opt.names={'Color' 'LineStyle' 'LineWidth'  'MarkerSize' 'displayname'};
    opt.values=[lineColorArray lineStyleArray lineWidthArray MarkerSizeArray displaynameArray];
    
elseif strcmp(style,'IVsZTES13')
    
    lineStyleArray([1:5],1)={'-'};
    lineStyleArray([6:10],1)={':'};
    lineStyleArray([11:15],1)={'--'};
    lineColorArray([1:5],1)=lineColors(1:5);
    lineColorArray([6:10],1)=lineColors(1:5);
    lineColorArray([11:15],1)=lineColors(1:5);
    lineWidthArray([1:15],1)={1};
    MarkerArray([1:5],1)={'.';'*';'+';'^';'v'};
    MarkerArray([6:10],1)={'.';'*';'+';'^';'v'};
    MarkerArray([11:15],1)={'.';'*';'+';'^';'v'};
    
    MarkerSizeArray([1:15],1)={4};
    MarkerSizeArray([1 6 11],1)={8};
    
    %%%ATENCI”N a la comilla ' al final {}';
    %displaynameArray={'40mK' '50mK' '60mK' '70mK' '80mK' '90mK' '95mK' '102mK' '104mK' '106mK' '110mK' '111mK' '112mK' '113mK' '114mK'}';%%%ZTES13
    %displaynameArray={'30mK' '40mK' '50mK' '60mK' '70mK' '80mK' '90mK' '95mK' '100mK' '105mK' '107mK' '108mK' '109mK' '110mK' '120mK'}';%%%ZTES26
    %displaynameArray={'40mK' '50mK' '60mK' '70mK' '80mK' '85mK' '90mK' '93mK' '95mK' '96mK' '98mK' '99mK' '100mK' '120mK' '200mK'}';%%%1Z1_54A
    %displaynameArray={'30mK' '40mK' '50mK' '60mK' '70mK' '80mK' '85mK' '90mK' '95mK' '96mK' '98mK' '100mK' '102mK' '105mK' '120mK' }';%%%1Z1_54B
     displaynameArray={'30mK' '40mK' '50mK' '60mK' '70mK' '80mK' '90mK' '100mK' '110mK' '115mK' '120mK' '125mK' '128mK' '135mK' '200mK'}';%%%1Z1_54B
    
    fontsize([1:15],1)={11};
    
    opt.names={'Color' 'LineStyle' 'LineWidth'  'Marker' 'MarkerSize' 'displayname'};
    opt.values=[ lineColorArray lineStyleArray lineWidthArray MarkerArray MarkerSizeArray displaynameArray];

elseif strcmp(style,'IVsZTES20')%sirve tb para ZTES18 cambiando Tbaths
    
    lineStyleArray([1:4],1)={'-'};
    lineStyleArray([5:8],1)={':'};
    lineStyleArray([9:12],1)={'--'};
    lineStyleArray([13:16],1)={'-.'};
    lineColorArray([1:4],1)=lineColors(1:4);
    lineColorArray([5:8],1)=lineColors(1:4);
    lineColorArray([9:12],1)=lineColors(1:4);
    lineColorArray([13:16],1)=lineColors(1:4);
    lineWidthArray([1:16],1)={1};
    MarkerArray([1:4],1)={'.';'*';'^';'v'};
    MarkerArray([5:8],1)={'.';'*';'^';'v'};
    MarkerArray([9:12],1)={'.';'*';'^';'v'};
    MarkerArray([13:16],1)={'.';'*';'^';'v'};
    
    MarkerSizeArray([1:16],1)={4};
    %MarkerSizeArray([1 6 11],1)={8};
    
    %displaynameArray={'32mK' '40mK' '45mK' '50mK' '55mK' '60mK' '65mK' '70mK' '75mK' '80mK' '85mK' '88mK' '89mK' '90mK' '92mK' '95mK'}';
    %displaynameArray={'40mK' '45mK' '50mK' '55mK' '60mK' '65mK' '70mK' '75mK' '80mK' '85mK' '87mK' '89mK' '90mK' '91mK' '92mK' '95mK'}';%%ZTES20
    %displaynameArray={'30mK' '40mK' '50mK' '60mK' '70mK' '80mK' '90mK' '100mK' '102mK' '104mK' '105mK' '106mK' '107mK' '108mK' '109mK' '110mK'}';%%%ZTES25
    displaynameArray={'35mK' '40mK' '50mK' '60mK' '70mK' '75mK' '80mK' '85mK' '90mK' '92mK' '94mK' '96mK' '97mK' '98mK' '100mK' '120mK'}';%%%1Z1_23A
    fontsize([1:16],1)={11};
    
    opt.names={'Color' 'LineStyle' 'LineWidth'  'Marker' 'MarkerSize' 'displayname'};
    opt.values=[ lineColorArray lineStyleArray lineWidthArray MarkerArray MarkerSizeArray displaynameArray];
    
elseif strcmp(style,'IVsZTES28')
    
    lineStyleArray([1:4],1)={'-'};
    lineStyleArray([5:8],1)={':'};
    lineStyleArray([9:12],1)={'--'};
  
    lineColorArray([1:4],1)=lineColors(1:4);
    lineColorArray([5:8],1)=lineColors(1:4);
    lineColorArray([9:12],1)=lineColors(1:4);

    lineWidthArray([1:12],1)={1};
    
    MarkerArray([1:4],1)={'.';'*';'^';'v'};
    MarkerArray([5:8],1)={'.';'*';'^';'v'};
    MarkerArray([9:12],1)={'.';'*';'^';'v'};
    
    MarkerSizeArray([1:12],1)={4};
    
    displaynameArray={'30mK' '40mK' '50mK' '60mK' '80mK' '90mK' '100mK' '105mK' '110mK' '112mK' '115mK' '200mK'}';
    %fontsize([1:12],1)={11};
    
    opt.names={'Color' 'LineStyle' 'LineWidth'  'Marker' 'MarkerSize' 'displayname'};
    opt.values=[ lineColorArray lineStyleArray lineWidthArray MarkerArray MarkerSizeArray displaynameArray];
    
elseif strcmp(style,'3param')
    
    lineStyleArray([1:3],1)={'--'};
    lineColorArray([1:3],1)={'b';'r';'k'};
    lineWidthArray([1:3],1)={2};
    MarkerArray([1:3],1)={'o';'^';'square'};
    MarkerSizeArray([1:3],1)={8};
    
    displaynameArray={ '90mK' '104mK' '108mK'}';
   
    opt.names={'Color' 'LineStyle' 'LineWidth'  'Marker' 'MarkerSize' 'displayname'};
    opt.values=[ lineColorArray lineStyleArray lineWidthArray MarkerArray MarkerSizeArray displaynameArray];
    
elseif strcmp(style,'9param')
        lineStyleArray([1:3],1)={'-'};
    lineStyleArray([4:6],1)={':'};
    lineStyleArray([7:9],1)={'--'};
    lineColorArray([1:3],1)=lineColors(1:3);
    lineColorArray([4:6],1)=lineColors(1:3);
    lineColorArray([7:9],1)=lineColors(1:3);
    lineWidthArray([1:9],1)={1};
    MarkerArray([1:3],1)={'.';'*';'+'};
    MarkerArray([4:6],1)={'.';'*';'+'};
    MarkerArray([7:9],1)={'.';'*';'+'};
    
    MarkerSizeArray([1:9],1)={4};
    MarkerSizeArray([1 4 7],1)={8};
    
    displaynameArray={'30mK' '40mK' '50mK' '60mK' '70mK' '80mK' '90mK' '100mK' '105mK'}';
    fontsize([1:9],1)={11};
    
    opt.names={'Color' 'LineStyle' 'LineWidth'  'Marker' 'MarkerSize' 'displayname'};
    opt.values=[ lineColorArray lineStyleArray lineWidthArray MarkerArray MarkerSizeArray displaynameArray];
end
%opt.names={'Color' 'LineStyle' 'LineWidth'  'MarkerSize' 'displayname'};
%opt.values=[lineColorArray lineStyleArray lineWidthArray MarkerSizeArray];
