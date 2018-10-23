function PlotParamListTES(param,varargin)
%%%%%Script para pintar un parámetro concreto 'param' para todos los TES
%%%%%cargados en el espacio de trabajo a una temperatura determinada. Dado
%%%%%que solo a 60mK y 80mK hay datos en todos los 5 TES, sólo se han
%%%%%implementado esas y se selecciona haciendo ind=ind60 o ind=ind80.
%%%%Se puede introducir un segundo parámetro y operar con el. Para ello
%%%%basta comentar la línea y2=1;


if nargin==2
    list=varargin{1};
else
%evalin('base','tes_list=who(''ZTES*'')')
list=evalin('base','who(''ZTES*'')')
%list=who('ZTES*');
end

% %%%Ojo, estos son los indices para el Parámetro P. No tienen pq coincidir
% %%%para las IVset!!!! Cuidado al mezclar parametros.
% %ind50=[nan 3 1 4 3 2 2 2  2 2 3 3];%%% 13(nan) 18(3) 20(1) 25(4) 26(3) 27(2) 28(2) 23A(2) 54A(2) 54B_Bi(3) 35A(3) 1Z10(2)
% %%%!!!!!! ojo, el 1Z10 no se lista el último, sino el primero de los 1Z.
% 
% %%%!!!!!!!!!!!!!!!!!!!!!!!!!!!
% ind50=[2 3 1 4 3 2 2 2 2 3 3]; %%%quito el Z27 de la lista para la TN. Y pongo los datos de 60mK del Z13.
% %%%!!!!!!!!!!!!!!!!!!!!!!!!!!
% ind60=[2 4 2 5 4 3 3 3 3 4 4 3];
% ind80=[3 7 6 7 6 4 4 5 5 6 6 5];
% indtc2=[2 3 1 4 4 3];
% %list=list([2 4:6]);indtc2=[3 5 4 3];ind60=[4 5 4 3];%%%Los TES sin Ruido.

%%%Finalmente implementación para poner automáticamente el índice
%%%correspondiente a una Tbase dada.
Tbase=0.05;
for i=1:length(list)
    Ts=evalin('base',strcat('[',list{i},'.P.Tbath]'))
    find(Ts==Tbase);
    if ~isempty(find(Ts==Tbase)) ind(i)=find(Ts==Tbase);else ind(i)=nan;end
end
ind
opt={'o-b' 'o-r' 'o-k' 'o-m' 'x-.b' 'x-.r' 'x-.k' 'x-.m' '^-b' '^-r' '^-k' '^-m'};%%% 12 markers

%%%%PARAMETROS:'rp', 'L0', 'ai', 'bi' 'tau0' 'taueff' 'C' 'Zinf' 'Z0'
%param='tau0';%%%%PONER EL NOMBRE DEL PARAMETRO A PINTAR
%ind=ind50;%%%%PONER ind60 o ind80 según al Tbath que se quiera usar.
param2='taueff';

hold off
listb={};

Rp=0.4;%0.375

for i=1:length(list)
    
    if strcmp(param,'RT')
        if evalin('base',strcat('isfield(',list{i},',''RT'')'))
            xrt=evalin('base',strcat('[',list{i},'.RT.temperatura]'));
            y=evalin('base',strcat('[',list{i},'.RT.resistencia]'));
        else 
            continue;
        end
    end
    %%%Para pintar la G
    if strcmp(param,'G') || strcmp(param,'n')
        if ~evalin('base',strcat('isfield(',list{i},'.Gset,''rp'')')), continue;end
         x2=evalin('base',strcat('[',list{i},'.Gset.rp]'));
        yg=evalin('base',strcat('[',list{i},'.Gset.G]'));
        yn=evalin('base',strcat('[',list{i},'.Gset.n]'));
        y=yg;
    end
    
    %if i==1||i==3 ,continue;end
    %listb{end+1}=list{i}
   {list{i},ind}
   
x=evalin('base',strcat('[',list{i},'.P(',num2str(ind(i)),').p.rp]'));

% yK=eval(strcat('[',list{i},'.Gset.K]'));
% yn=eval(strcat('[',list{i},'.Gset.n]'));
% 
% x3=eval(strcat('[',list{i},'.IVset(ind(',num2str(i),')).rtes]'));
% yP=eval(strcat('[',list{i},'.IVset(ind(',num2str(i),')).ptes]'));
% 
% xiv=eval(strcat('0.5*([',list{i},'.IVset(ind(',num2str(i),')).rtes(1:end-1)]+[',list{i},'.IVset(ind(',num2str(i),')).rtes(2:end)])'));
% alfaiv=eval(strcat('[diff(log(',list{i},'.IVset(ind(',num2str(i),')).Rtes))]./[diff(log(',list{i},'.IVset(ind(',num2str(i),')).ttes))]'));

if ~strcmp(param,'G') && ~strcmp(param,'n') && ~strcmp(param,'RT')
    if ~evalin('base',strcat('isfield(',list{i},'.P(',num2str(ind(i)),').p,''',param,''')')), continue;end
    y_str=strcat('[',list{i},'.P(',num2str(ind(i)),').p.',param,']');
    y=evalin('base',y_str);
end
listb{end+1}=list{i}
% y2_str=strcat('[',list{i},'.P(ind(',num2str(i),')).p.',param2,']');
% y2=eval(y2_str);
%y2=1;

% %M=eval(strcat('[',list{i},'.P(ind(',num2str(i),')).p.','M',']'));
% n=eval(strcat('[',list{i},'.TES.n]'));
% K=eval(strcat('[',list{i},'.TES.K]'));
% Tc=eval(strcat('[',list{i},'.TES.Tc]'));
% Rn=eval(strcat('[',list{i},'.TES.Rn]'));
% Tcarr(i)=Tc;
% C=eval(strcat('[',list{i},'.TES.C]'));
% G=eval(strcat('[',list{i},'.TES.G]'));
% Tau0arr(i)=C/G;
% Cth=eval(strcat('[',list{i},'.TES.Cth]'));
% %M=4;

    %%%%%%%%%%%%%%%%%%%%%%%Para pintar en función de Tbath
%    TbathArray=evalin('base',strcat('[',list{i},'.P.Tbath]'))
%     yT=[];yT2=[];
%     for j=1:length(TbathArray)
%         xaux=evalin('base',strcat('[',list{i},'.P(',num2str(j),').p.rp]'));
%         yaux=evalin('base',strcat('[',list{i},'.P(',num2str(j),').p.',param,']'));
%         %yaux2=eval(strcat('[',list{i},'.P(',num2str(j),').p.',param2,']'));
%         yT(j)=spline(xaux,yaux,Rp);
%         %yT2(j)=spline(xaux,yaux2,Rp);
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ii,jj]=sort(x);
%%ff=y(jj).*(2.5e-3+y2(jj));%%%Llimite.Irwin book ec(53).
%ff=2.355*sqrt(4*1.38e-23*Tc^2*C./y.*sqrt(n*(1+M.^2)/2))/1.609e-19;%%%Resolucion teorica
%ff=y./y2;

%x_plot=x2;
x_plot=x;
y_plot=y;
ymin=0.3*median(y_plot);
y_range='auto';
x_range=[0.15 0.9];
x_label='R_{TES}/R_n';

switch param
    case 'C'
        y_plot=y_plot*1e15;
        label='C(fJ/K)';
    case 'taueff'
        y_plot=y_plot*1e6;
        label='\tau_{eff} (\mus)';
    case 'ai'
        label='\alpha_i';
        y_plot=abs(y_plot);
        ymin=0.33;
    case 'bi'
        label='\beta_i';
    case 'M'
        label='M_{johnson}';
    case 'Mph'
        label='M_{phonon}';
    case 'ExRes'
        label='\DeltaE_{baseline} (eV)';
    case 'G'
        x_plot=x2;
        y_plot=yg;
        label='G(pW/K)';
    case 'n'
        x_plot=x2;
        y_plot=yn;
        label='n';
        y_range=[2 5];
%     case 'tauT'
%         x_plot=TbathArray;
%         y_plot=yT;
%         label='\tau_{eff} (\mus) vs T_{bath}';
    case 'RT'
        x_plot=xrt;
        y_plot=medfilt1(y*1e3,5);
        label='R(T) (m\Omega)';
        x_label='T(K)';
        x_range=[0.08 0.14];%%%[0.08 0.3] para todos, [0.08 0.14] para pintar sin Z13 ni Z27
        
    otherwise
        label=param;
end
indplot=find(y_plot<3*median(y_plot) & y_plot>ymin);%%%Para filtrar
indplot=1:length(y_plot);%%%Para no filtrar

%y_plot=ones(1,length(x_plot))*K*Tc^n;%3*yg/100;
%plot(x_plot(ind),y_plot(ind),opt{i-1},'linewidth',2),hold on
%plot(x_plot(ind),y_plot(ind),opt{i},'linewidth',2),hold on
if floor((length(listb)-1)/7) opt='v-';else opt='o-';end
h=plot(x_plot(indplot),y_plot(indplot),opt,'linewidth',1,'markersize',5);hold on
set(h,'markerfacecolor',get(h,'color'));

%plot(Tc,C./G,opt{i},'linewidth',2),hold on %%%mod(i-1,8)+1
%plot(x,Tc*sqrt(y./y2),opt{i-1},'linewidth',2),hold on%%% si y=C,y2=alfa ->FoM
%plot(x,y.*(y2+2e-3),opt{i-1},'linewidth',2),hold on %Lcrit
%plot(x,y,opt{i-1},'linewidth',2),hold on
%plot(TbathArray/Tc,abs(yT2),opt{i-1},'linewidth',2),hold on
%plot(yT(ind(i)),yT2(ind(i)),opt{i-1},'linewidth',2),hold on
%plot(x,Cth*ones(1,length(x)),opt{mod(i-1,8)+1},'linewidth',2)
%plot(x2,yg,opt{i-1}),hold on

%plot(xiv,alfaiv,opt{mod(i-1,8)+1},'linewidth',2),hold on%%%x,y

end

if strcmpi(param,'bi')
    plot(0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2);
end

grid on;
xlabel(x_label,'fontsize',12,'fontweight','bold');
%xlabel('\alpha_i','fontsize',12);
ylabel(label,'fontsize',12,'fontweight','bold');
%ylabel('L_{limite}','fontsize',12);
listbLG=strrep(strrep(listb,'_DATA',''),'DATA','');
legend(listbLG,'interpreter','none','Location','best');
set(gca,'linewidth',2,'fontsize',12,'fontweight','bold');
xlim(x_range);
ylim(y_range);
if strcmpi(param,'bi')
    plot(0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2);
end
% plot([ZTES13DATA.P(ind(1)).p.rp],[ZTES13DATA.P(ind(1)).p.ai],'.-')
% plot([ZTES18DATA.P(ind(2)).p.rp],[ZTES18DATA.P(ind(2)).p.ai],'.-r')
% plot([ZTES20DATA.P(ind(3)).p.rp],[ZTES20DATA.P(ind(3)).p.ai],'.-k')
% plot([ZTES25DATA.P(ind(4)).p.rp],[ZTES25DATA.P(ind(4)).p.ai],'.-m')
% plot([ZTES26DATA.P(ind(5)).p.rp],[ZTES26DATA.P(ind(5)).p.ai],'.-g')