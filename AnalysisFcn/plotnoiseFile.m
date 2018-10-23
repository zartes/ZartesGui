function si0 = plotnoiseFile(IVset,P,ZTESDATA,varargin)
%pinta ruido y compara con Irwin a partir de fichero
%V170112. IVstr es la estructura a la temperatura de interÃ©s, y p es la
%estructura de parÃ¡metros tambiÃ©n a esa temepratura.

%v170113. Paso ya el IVset completo y P completo.

%v170621. Puedo pasar estructura con opciones de pintado.

% wdir = strcat(num2str(IVstr.Tbath*1e3),'mK');
% if nargin>4
%     %wdir = varargin{1};
%     wfiles = varargin{1};
%     [noise,file] = loadnoise(0,wdir,wfiles);
% else
%     %%%listar ficheros
%     d = pwd;
%     strcat(d,'\',wdir)
%     D = dir(strcat(d,'\',wdir,'\HP*'));
%     [~,s2] = sort([D(:).datenum]',1,'descend');
%     filesNoise = {D(s2).name}%%%ficheros en orden de %Rn!!!
%
%     [noise,file] = loadnoise(0,wdir,filesNoise);
% end

% option.tipo = 'current';
% option.boolcomponents = 0;
% option.Mph = 0;
% option.Mjo = 0;
% 
% %NoiseBaseName = 'HP_noise';
% NoiseBaseName = 'PXI_noise';

if nargin == 4
    [noise,file,path] = loadnoise();
    %%%buscamos la IV y P correspondientes a la Tbath dada
    %     path;
    auxstr = char(regexp(path,'\d*(.\d*)?mK','match'));
    Tbath = sscanf(strrep(auxstr,'\',''),'%fmK'); %se hace necesario este apaño porque al ejecutar desde Directorio de datos general path contiene '\' y da error.
    [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr = IVset(Tind);
    [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
    p = P(Tind).p;
end
if nargin == 5
    if isstruct(varargin{1})
        option = varargin{1};
        [noise,file,path] = loadnoise();
        %%%buscamos la IV y P correspondientes a la Tbath dada
        %             path
        auxstr = char(regexp(path,'\d*(.\d*)?mK','match'));
        Tbath = sscanf(strrep(auxstr,'\',''),'%fmK');%se hace necesario este apaño porque al ejecutar desde Directorio de datos general path contiene '\' y da error.
        [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IVstr = IVset(Tind);
        [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
        p = P(Tind).p;
    else
        wdir = varargin{1};
        %     d = pwd;
        %     D = dir(strcat(d,'\',wdir,'\HP*'));
        %     [~,s2] = sort([D(:).datenum]',1,'descend');
        %     filesNoise = {D(s2).name}%%%ficheros en orden de %Rn!!!
        filesNoise = ListInBiasOrder(strcat(wdir,'\',NoiseBaseName,'*'),'ascend');
        [noise,file] = loadnoise(0,wdir,filesNoise);
        Tbath = sscanf(wdir,'%dmK');
        [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IVstr = IVset(Tind);
        [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
        p = P(Tind).p;
    end
end
if nargin == 6
    if isstruct(varargin{2})
        option = varargin{3};
        wdir = varargin{1};
        filesNoise = varargin{2};
        %         d = pwd;
        %     D = dir(strcat(d,'\',wdir,'\HP*'));
        %     [~,s2] = sort([D(:).datenum]',1,'descend');
        %     filesNoise = {D(s2).name}%%%ficheros en orden de %Rn!!!
        %strcat(wdir,'\HP*')
%         filesNoise = ListInBiasOrder(strcat(wdir,'\',option.NoiseBaseName,'*'),'ascend');
        [noise,file] = loadnoise(0,wdir,filesNoise);
        Path = wdir(find(wdir(1:end-1) == filesep, 1, 'last' )+1:end);
        Tbath = sscanf(Path,'%dmK\');        
%         Tbath = sscanf(wdir,'%dmK');
        [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IVstr = IVset(Tind);
        [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
        p = P(Tind).p;
    else
        option = varargin{3};
        wdir = varargin{1};
        wfiles = varargin{2};
        [noise,file] = loadnoise(0,wdir,wfiles);
        Path = wdir(find(wdir(1:end-1) == filesep, 1, 'last' )+1:end);
        Tbath = sscanf(Path,'%dmK\');    
%         Tbath = sscanf(wdir,'%dmK');
        [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IVstr = IVset(Tind);
        [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
        p = P(Tind).p;
    end
end
if nargin == 7
    wdir = varargin{1};
    wfiles = varargin{2};
    option = varargin{3};
    [noise,file] = loadnoise(0,wdir,wfiles);
    Tbath = sscanf(wdir(max(find(wdir(1:end-1) == filesep))+1:end),'%dmK\');
%     Tbath = sscanf(wdir,'%dmK\');
    [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr = IVset(Tind);
    [~,Tind] = min(abs([P.Tbath]*1e3-Tbath));
    p = P(Tind).p;
end

% [IVstr.Tbath]
% [P(Tind).Tbath]

%tipo = 'current';%%% 'NEP' or 'current'
%tipo = 'NEP';
tipo = option.tipo;
boolcomponents = option.boolcomponents;%%%%para pintar o no las componentes
Mph = option.Mph;
Mjo = option.Mjo;
NoiseBaseName = option.NoiseBaseName(2:end-1);

figure

if ~iscell(file)
    file = {file};
end
if iscell(file)
    N = length(file);
    for i = 1:N
        %         i
        %         file{i}
        %         strcat(NoiseBaseName,'_%fuA*')
        Ib = sscanf(file{i},strcat(NoiseBaseName,'_%fuA.txt'))*1e-6; %%%HP_noise para ZTES18.!!!
        OP = setTESOPfromIb(Ib,IVstr,p,ZTESDATA);
        %%OP.Tbath = 1.5*OP.Tbath;%%%effect of Tbath error.Despreciable.
        [ncols,nrows] = SmartSplit(N); %#ok<ASGLU>
        %         nrows = 4;
        %         ncols = max(ceil(N/nrows),1);
        subplot(ceil(N/ncols),ncols,i);
        %hold off;%figure
        
        %%ZTES.Tc = 1.3*ZTES.Tc;%%effect of Tc error.
        %auxnoise = plotnoise('irwin',ZTES,OP,circuit,0);hold on;%%%quinto argumento 'M'.
        
        if Mjo == 1
            M = OP.M;
        else
            M = 0;
        end
        
        auxnoise = noisesim('irwin',ZTESDATA.TES,OP,ZTESDATA.circuit,M);
        f = logspace(0,6,1000);
        %si0(i) = auxnoise.sI(1);
        si0 = auxnoise;%debug,para N = 1 ver la SI.
        
        if strcmp(tipo,'current')
            
            loglog(noise{i}(:,1),V2I(noise{i}(:,2)*1e12,ZTESDATA.circuit),'.-r'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            loglog(noise{i}(:,1),medfilt1(V2I(noise{i}(:,2)*1e12,ZTESDATA.circuit),20),'.-k'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            %loglog(noise{i}(:,1),sgolayfilt(V2I(noise{i}(:,2)*1e12,circuit),3,41),'.-k'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            if Mph == 0
                totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
            else
                %                     totnoise = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                Mexph = OP.Mph;
                totnoise = sqrt((auxnoise.ph*(1+Mexph^2)).^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
            end
            %%%normalization test
            %ind = find(noise{i}(:,1)>100&noise{i}(:,1)<1000);
            %loglog(noise{i}(:,1),noise{i}(:,2)/median(noise{i}(ind,2)),'.-r'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
            %totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2)/auxnoise.sI(1);
            
            %totnoise = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);%%%To make F = 1;
            
            if ~boolcomponents
                %loglog(f,totnoise/totnoise(1));%%para pintar normalizados.
                loglog(f,totnoise*1e12,'b');
                h = findobj(gca,'color','b');
                %legend({'Experimental','STM'})
                
            else
                loglog(f,auxnoise.jo*1e12,f,auxnoise.ph*1e12,f,auxnoise.sh*1e12,f,totnoise*1e12);
                %legend('experimental','jhonson','phonon','shunt','total');
                legend('experimental','exp\_filtered','jhonson','phonon','shunt','total');
                h = findobj(gca,'displayname','total');
            end
            ylabel('pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
            
        elseif strcmpi(tipo,'nep')
            
            sIaux = ppval(spline(f,auxnoise.sI),noise{i}(:,1));
            NEP = real(sqrt((V2I(noise{i}(:,2),ZTESDATA.circuit).^2-auxnoise.squid.^2))./sIaux);
            loglog(noise{i}(:,1),(NEP*1e18),'.-r'),hold on,grid on,
            loglog(noise{i}(:,1),medfilt1(NEP*1e18,20),'.-k'),hold on,grid on,
            %loglog(noise{i}(:,1),sgolayfilt(NEP*1e18,3,41),'.-k'),hold on,grid on,
            if Mph == 0
                totNEP = auxnoise.NEP;
            else
                totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
            end
            if ~boolcomponents
                loglog(f,totNEP*1e18,'b');hold on;grid on;
                h = findobj(gca,'color','b');
            else
                loglog(f,auxnoise.jo*1e18./auxnoise.sI,f,auxnoise.ph*1e18./auxnoise.sI,f,auxnoise.sh*1e18./auxnoise.sI,f,(totNEP*1e18));
                %legend('experimental','jhonson','phonon','shunt','total');
                legend('experimental','exp\_filtered','jhonson','phonon','shunt','total');
                h = findobj(gca,'displayname','total');
            end
            ylabel('aW/Hz^{0.5}','fontsize',12,'fontweight','bold')
        end
        xlabel('\nu (Hz)','fontsize',12,'fontweight','bold')
        
        
        axis([1e1 1e5 2 1e3])%% axis([1e1 1e5 1 1e4])
        
        %h = get(gca,'children')
        set(h(1),'linewidth',3);
        set(gca,'fontsize',11,'fontweight','bold');
        set(gca,'linewidth',2)
        set(gca,'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-')
        set(gca,'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'})
        title(strcat(num2str(round(OP.r0*100)),'%Rn'),'fontsize',12);
%         OP.Z0,OP.Zinf
        %debug
        if abs(OP.Z0-OP.Zinf) < 1.5e-3
            set(get(findobj(gca,'type','axes'),'title'),'color','r');
        end
        
        %%%obsolet0.
        %          if(0)
        %          sIaux = ppval(spline(f,auxnoise.sI),noise{i}(:,1));
        %          NEP = sqrt((V2I(noise{i}(:,2),circuit).^2-auxnoise.squid.^2))./sIaux;
        %          %figure
        %             loglog(noise{i}(:,1),NEP*1e18,'r'),hold on,grid on,%%%for noise in Power
        %          %   loglog(f,auxnoise.NEP*1e18,'b'),hold on,grid on,%%%for noise in Power
        %
        %          %%resolucion experimental o teorica. Devolver un parametro u otro.
        %          expres(1,i) = OP.R0/ZTES.Rn;
        %          RES = 2.35/sqrt(trapz(noise{i}(:,1),1./NEP.^2))/2/1.609e-19;
        %          expres(2,i) = RES;
        %          thres(1,i) = OP.R0/ZTES.Rn;
        %          thres(2,i) = auxnoise.Res;
        %          end
        
        %set(gca,'xlim',[100 1e5]);
        %set(gca,'ylim',[1e-11 1e-9]);
        %set(gca,'ylim',[1e-18 1e-16]);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Salvar la figura
        %num2str(gcf) deja de funcionar en matlab2015a
        n = get(gcf,'number');
        fi = strcat('-f',num2str(n));
        mkdir('figs');
        name = strcat('figs\Noise',num2str(Tbath),'mK');
        print(fi,name,'-dpng','-r0');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%Pruebas sobre la cotribución de cada frecuencia a la
        %%%%Resolucion.
        if strcmpi(tipo,'nep') && 0
            figure
            %RESJ = sqrt(2*log(2)./trapz(f,1./medfilt1(totNEP,1).^2));%%%x = noisedata{1}(:,1);
            RESJ = sqrt(2*log(2)./trapz(f,1./totNEP.^2));
            disp(num2str(RESJ));
            %semilogx(f(1:end-1),((RESJ./totNEP(1:end-1)).^2/(2*log(2)).*diff(f))),hold on
            semilogx(f(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(f))))/1.609e-19),hold on
            fx = noise{i}(:,1);
            RESJ2 = sqrt(2*log(2)./trapz(fx,1./NEP.^2));
            disp(num2str(RESJ2));
            %semilogx(fx(1:end-1),((RESJ2./NEP(1:end-1)).^2/(2*log(2)).*diff(fx)),'r')
            semilogx(fx(1:end-1),sqrt((2*log(2)./cumsum(1./NEP(1:end-1).^2.*diff(fx))))/1.609e-19,'r')
            %semilogx(fx(1:end-1),((RESJ2./medfilt1(NEP(1:end-1),20)).^2/(2*log(2)).*diff(fx)),'k')
        end
    end
else
    
    Ib = sscanf(file,strcat(NoiseBaseName,'_%duA*'))*1e-6;
    OP = setTESOPfromIb(Ib,IVstr,p);
    
    hold off;%figure
    %loglog(noise(:,1),V2I(noise(:,2),circuit.Rf),'r'),hold on,grid on,%%%for noise in Current
    loglog(noise(:,1),V2I(noise(:,2),ZTESDATA.circuit).*OP.V0,'r'),hold on,grid on,%%%for noise in Power
    plotnoise('irwin',ZTESDATA.TES,OP,ZTESDATA.circuit)
end


