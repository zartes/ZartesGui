function si0=plotnoiseFile(IVset,P,circuit,ZTES,varargin)
%pinta ruido y compara con Irwin a partir de fichero
%V170112. IVstr es la estructura a la temperatura de interÃ©s, y p es la
%estructura de parÃ¡metros tambiÃ©n a esa temepratura.

%v170113. Paso ya el IVset completo y P completo.

%v170621. Puedo pasar estructura con opciones de pintado.

% wdir=strcat(num2str(IVstr.Tbath*1e3),'mK');
% if nargin>4
%     %wdir=varargin{1};
%     wfiles=varargin{1};
%     [noise,file]=loadnoise(0,wdir,wfiles);
% else
%     %%%listar ficheros
%     d=pwd;
%     strcat(d,'\',wdir)
%     D=dir(strcat(d,'\',wdir,'\HP*'));
%     [~,s2]=sort([D(:).datenum]',1,'descend');
%     filesNoise={D(s2).name}%%%ficheros en orden de %Rn!!!
% 
%     [noise,file]=loadnoise(0,wdir,filesNoise);
% end

option.tipo='current';
option.boolcomponents=0;
option.Mph=0;
option.Mjo=0;
option.NoiseBaseName='HP_noise';
NoiseBaseName=option.NoiseBaseName;%%%%Añadimos campo a option para elegir si pintar ruidos del HP o de la PXI.
%NoiseBaseName='PXI_noise';

%NoiseBaseName. Para poder usar PXI o HP sólo en NoisePlotOptions
if isempty(strfind(NoiseBaseName,'PXI'))
    NoiseBaseName='\HP_noise*';
else
    NoiseBaseName='\PXI_noise*';
end

if nargin==4
    [noise,file,path]=loadnoise();
    %%%buscamos la IV y P correspondientes a la Tbath dada
    path
    auxstr=char(regexp(path,'\d*(.\d*)?mK','match'));
    Tbath=sscanf(strrep(auxstr,'\',''),'%fmK'); %se hace necesario este apaño porque al ejecutar desde Directorio de datos general path contiene '\' y da error.
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
    p=P(Tind).p;
end
if nargin==5
    if isstruct(varargin{1}) %%%si el primer parametro extra es estructura, se interpreta como la 'option'.
        option=varargin{1};
            [noise,file,path]=loadnoise();
            %%%buscamos la IV y P correspondientes a la Tbath dada
            path
            auxstr=char(regexp(path,'\d*(.\d*)?mK','match'));
            Tbath=sscanf(strrep(auxstr,'\',''),'%fmK');%se hace necesario este apaño porque al ejecutar desde Directorio de datos general path contiene '\' y da error.
            [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
            IVstr=IVset(Tind);
            [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
            p=P(Tind).p;
    else  %%%% si no es estructura, se interpreta como el directorio a analizar.
    wdir=varargin{1};
    d=pwd;
%     D=dir(strcat(d,'\',wdir,'\HP*'));
%     [~,s2]=sort([D(:).datenum]',1,'descend');
%     filesNoise={D(s2).name}%%%ficheros en orden de %Rn!!!
    filesNoise=ListInBiasOrder(strcat(wdir,'\',NoiseBaseName,'*'),'ascend')
    [noise,file]=loadnoise(0,wdir,filesNoise);
    Tbath=sscanf(wdir,'%dmK');
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
    p=P(Tind).p;
    end
end
if nargin==6     
    if isstruct(varargin{2})%%%%Si hay dos parámetros extra el primero es el wdir, y el segundo si es estructura es la 'option' y si no, son los files a pintar.
        option=varargin{2};
        wdir=varargin{1};
        d=pwd;
        %     D=dir(strcat(d,'\',wdir,'\HP*'));
        %     [~,s2]=sort([D(:).datenum]',1,'descend');
        %     filesNoise={D(s2).name}%%%ficheros en orden de %Rn!!!
        %strcat(wdir,'\HP*')
        filesNoise=ListInBiasOrder(strcat(wdir,'\',NoiseBaseName,'*'),'ascend')
        [noise,file]=loadnoise(0,wdir,filesNoise);
        Tbath=sscanf(wdir,'%dmK');
        [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IVstr=IVset(Tind);
        [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
        p=P(Tind).p;
    else
    wdir=varargin{1};
    wfiles=varargin{2};
   [noise,file]=loadnoise(0,wdir,wfiles);
      Tbath=sscanf(wdir,'%dmK');
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
    p=P(Tind).p;
    end
end 
if nargin==7 %%%%Se puede pasar también tanto el directorio, como los ficheros, como la option, en ese orden.
    wdir=varargin{1};
    wfiles=varargin{2};
    option=varargin{3};
   [noise,file]=loadnoise(0,wdir,wfiles);
      Tbath=sscanf(wdir,'%dmK');
    [~,Tind]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [~,Tind]=min(abs([P.Tbath]*1e3-Tbath));
    p=P(Tind).p;
    NoiseBaseName=option.NoiseBaseName;
    if isempty(strfind(NoiseBaseName,'PXI'))
        NoiseBaseName='\HP_noise*';
    else
        NoiseBaseName='\PXI_noise*';
    end
    AllfilesNoise=ListInBiasOrder(strcat(wdir,'\',NoiseBaseName,'*'),'descend');
end

tipo=option.tipo;
boolcomponents=option.boolcomponents;%%%%para pintar o no las componentes
Mph=option.Mph;
Mjo=option.Mjo;
NoiseBaseName=regexp(NoiseBaseName,'(PXI|HP)_noise','match');%%%%%!!!!!El patrón en option es: '\(PXI|HP)_noise*', pero para sacar el Ibias se necesita '(PXI|HP)_noise' !!!! 
NoiseBaseName=NoiseBaseName{1};%%%%convert cell 2 string.

if ~iscell(file) file={file};end
if iscell(file)
    N=length(file);    
    for i=1:N
        i,file{i}
        %strcat(NoiseBaseName,'_%fuA*')
        Ib=sscanf(file{i},strcat(NoiseBaseName,'_%fuA*'))*1e-6 %%%HP_noise para ZTES18.!!!
        %length(p)
        indx=strcmp(AllfilesNoise,deblank(file{i}));%%%no funciona si el nombre del file tiene espacio en blanco.
        %%%ojo, el AllfilesNoise sólo está definido cuando se llama la
        %%%funcio´n con 7 parámetros.
        OP=setTESOPfromIb(Ib,IVstr,p(indx),circuit)
        
        %%%intento de pasar la ztes experimental para el modelo de ruido.
        %%%En realidad no lo estamos usando y no gestiona bien si TF es con
        %%%HP y ruidos con PXI.
        boolZexp=0;
        if boolZexp
            if isempty(strfind(NoiseBaseName,'PXI'))
                zfile=strrep(file{i},NoiseBaseName,'TF')
                tfs=importTF('TFS_HP.txt');
            else
                zfile=strrep(file{i},NoiseBaseName,'PXI_TF')
                tfs=importTF('TFS_PXI.txt');
            end
            auxTF=importTF(strcat(wdir,'\',zfile));
            %tfs=importTF();
            auxZ=GetZfromTF(auxTF,tfs,circuit);
            OP.ztes.data=auxZ.tf;
            OP.ztes.freqs=auxZ.f;
        end
        %%%%
        
        %%OP.Tbath=1.5*OP.Tbath;%%%effect of Tbath error.Despreciable.
        [ncols,nrows]=SmartSplit(N);
%         nrows=4;
%         ncols=max(ceil(N/nrows),1);
        subplot(ceil(N/ncols),ncols,i);
        %hold off;%figure
        
        %%ZTES.Tc=1.3*ZTES.Tc;%%effect of Tc error.
        %auxnoise=plotnoise('irwin',ZTES,OP,circuit,0);hold on;%%%quinto argumento 'M'.
        
        if Mjo==1
            M=OP.M;
        else
            M=0;
        end
        
        if isfield(option,'model')
            modelname=option.model;
        else
            modelname='irwin';
        end
        
        if strfind(modelname,'2TB')
            OP.parray=[p(indx).Zinf p(indx).Z0 p(indx).taueff p(indx).geff p(indx).t_1];
        end
        auxnoise=noisesim(modelname,ZTES,OP,circuit,M);
        %auxnoise=noisesim('irwin',ZTES,OP,circuit,M);
        
        f=logspace(0,6,1000);
        %si0(i)=auxnoise.sI(1);
        %si0=auxnoise;%debug,para N=1 ver la SI.
        %medfilt_w=20;
        optfilt.model='movingMean';%'quantile';%'movingMean';%'minfilt+medfilt';%
        optfilt.wmed=20;%200;
        optfilt.wmin=6;%200;
        optfilt.thr=10;%%%porcentaje para el movingMean.
        optfilt.perc=0.2;
        if isfield(option,'FiltOpt')
            optfilt=option.FiltOpt;
        end
        if isfield(option,'NoiseSubsampleFreqs')
            newfreqs=option.NoiseSubsampleFreqs;
            newnoise=interp1(noise{i}(:,1),noise{i}(:,2),newfreqs);
            noise{i}=[];
            noise{i}(:,1)=newfreqs;
            noise{i}(:,2)=newnoise;
        end
            if(strcmp(tipo,'current'))
                 %filtered_current_noise=medfilt1(V2I(noise{i}(:,2),circuit)*1e12,medfilt_w);
                 filtered_current_noise=filterNoise(V2I(noise{i}(:,2),circuit)*1e12,optfilt);
                 %filtered_current_noise=colfilt(V2I(noise{i}(:,2),circuit)*1e12,[10 1],'sliding',@min);
                 %filtered_current_noise=colfilt(V2I(noise{i}(:,2),circuit)*1e12,[10 1],'sliding',@mean);
                 %filtered_current_noise=medfilt1(filtered_current_noise,40);
                 loglog(noise{i}(:,1),V2I(noise{i}(:,2),circuit)*1e12,'.-r'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                 loglog(noise{i}(:,1),filtered_current_noise,'.-k'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                
                %loglog(noise{i}(:,1),sgolayfilt(V2I(noise{i}(:,2)*1e12,circuit),3,41),'.-k'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                if Mph==0
                    %tottes2=(auxnoise.ph.^2)+auxnoise.jo.^2+auxnoise.sh.^2;
                    %%%esto es equivalente a auxnoise.sum pero si sustituyo .ph por .max
                    %%%puedo ver el efecto de hacer F=1. Se ve que no es
                    %%%suficiente en muchos casos, aunque puede ser por la
                    %%%cantidad de picos. Algunos mínimos sí coinciden con
                    %%%.max.Pero ojo, porque sólo vale para 1TB.
                    tottes2=auxnoise.sum.^2;
                    totnoise=sqrt(tottes2+auxnoise.squidarray.^2);
                    Mexph=0;
                    circuitnoise=auxnoise.squidarray;
                else
                    %%%%%OJO, PARA modelos 2TB no existe noise.ph ya que
                    %%%%%hay 2 componentes de ph diferentes por tanto
                    %%%%%totnoise no se puede definir así.
                    %totnoise=sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                    
                    if strfind(modelname,'irwin')
                        Mexph=OP.Mph;
                        circuitnoise=auxnoise.squidarray;
                        if isfield(circuit,'circuitnoise') 
                            cn=circuit.circuitnoise;
                            circuitnoise=interp1(cn(:,1),cn(:,2),f);
                        end
                        totnoise=sqrt((auxnoise.ph.^2)*(1+Mexph^2)+auxnoise.jo.^2+auxnoise.sh.^2+circuitnoise.^2);
                    elseif strfind(modelname,'2TB')
                        Mph1=OP.Mph;
                        Mph2=OP.Mph2;
                        %%%M(1) es el ph_tes-bloque1, M(2) es el
                        %%%ph_bloque1-baño.
                        
                        totnoise=sqrt((auxnoise.ph_t1.^2)*(1+Mph1^2)+(auxnoise.ph_1b.^2)*(1+Mph2^2)+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                        
                    end
                end
                %%%normalization test
                %ind=find(noise{i}(:,1)>100&noise{i}(:,1)<1000);
                %loglog(noise{i}(:,1),noise{i}(:,2)/median(noise{i}(ind,2)),'.-r'),hold on,grid on,%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                %totnoise=sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2)/auxnoise.sI(1);
                
                %totnoise=sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);%%%To make F=1;

                if ~boolcomponents
                    %loglog(f,totnoise/totnoise(1));%%para pintar normalizados.
                    
                    if OP.r0>=0.91 totnoise=NnoiseModel(circuit,Tbath*1e-3);end%%%Una prueba para pintar el modelo de ruido 'N' a alto %Rn.
                    %totnoise(1)
                    if  Ib<OP.Ibiasmin totnoise=SnoiseModel(circuit,Tbath*1e-3);end %%%para pintar el modelo 'S' 
                    loglog(f,totnoise*1e12,'b');
                    h=findobj(gca,'color','b');
                    %legend({'Experimental','STM'})
                    
                else
                    %%%Esto sólo vale para 1TB.
                    i_jo=auxnoise.jo*1e12;
                    i_sh=auxnoise.sh*1e12;
                    fcomponentnames=fieldnames(auxnoise);
                    kkk_ph=1;
                    for iii_ph=1:length(fcomponentnames)
                        if strfind(fcomponentnames{iii_ph},'ph') 
                            i_ph(kkk_ph,:)=auxnoise.(fcomponentnames{iii_ph})*1e12;
                            kkk_ph=kkk_ph+1;
                        end
                    end
                    %loglog(f,auxnoise.jo*1e12,f,auxnoise.ph*1e12,f,auxnoise.sh*1e12,f,totnoise*1e12);
                    if kkk_ph==2
                        loglog(f,i_jo,f,i_ph*sqrt(1+Mexph^2),f,i_sh,f,circuitnoise*1e12,f,totnoise*1e12);
                        legend('experimental','exp\_filtered','johnson','phonon','shunt','electronics','total');
                    elseif kkk_ph==3
                        loglog(f,i_jo,f,i_ph(1,:),f,i_ph(2,:),f,i_sh,f,totnoise*1e12);
                        legend('experimental','exp\_filtered','johnson','phonon\_1','phonon\_2','shunt','total');
                    end
                    %legend('experimental','johnson','phonon','shunt','total');
                    %legend('experimental','exp\_filtered','jhonson','phonon','shunt','total');
                    h=findobj(gca,'displayname','total');
                end
                ylabel('pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
                
            elseif (strcmpi(tipo,'nep'))
                
                sIaux=ppval(spline(f,auxnoise.sI),noise{i}(:,1));
                NEP=sqrt((V2I(noise{i}(:,2),circuit).^2-auxnoise.squid.^2))./abs(sIaux);
                %filtered_power_noise=medfilt1(NEP*1e18,medfilt_w);
                filtered_power_noise=filterNoise(NEP*1e18,optfilt);
                loglog(noise{i}(:,1),(NEP*1e18),'.-r'),hold on,grid on,
                loglog(noise{i}(:,1),filtered_power_noise,'.-k'),hold on,grid on,
                %loglog(noise{i}(:,1),sgolayfilt(NEP*1e18,3,41),'.-k'),hold on,grid on,
                    if Mph==0
                        totNEP=auxnoise.NEP;
                        Mexph=0;
                    else
                        %totNEP=sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F=1, no tiene porqué.
                        Mexph=OP.Mph;
                        totNEP=sqrt((auxnoise.ph.^2)*(1+Mexph^2)+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;    
                    end
                if ~boolcomponents
                    loglog(f,totNEP*1e18,'b');hold on;grid on;
                    h=findobj(gca,'color','b');
                else
                    %%%Esto sólo vale para 1TB.
                    loglog(f,auxnoise.jo*1e18./auxnoise.sI,f,sqrt(1+Mexph^2)*auxnoise.ph*1e18./auxnoise.sI,f,auxnoise.sh*1e18./auxnoise.sI,f,(totNEP*1e18));
                    %legend('experimental','johnson','phonon','shunt','total');
                    legend('experimental','exp\_filtered','johnson','phonon','shunt','total');
                    h=findobj(gca,'displayname','total');
                end
               ylabel('aW/Hz^{0.5}','fontsize',12,'fontweight','bold')
            end
            xlabel('\nu (Hz)','fontsize',12,'fontweight','bold')
            
            
        axis([1e1 1e5 1e1 1e3])%% axis([1e1 1e5 1 1e4])

        %h=get(gca,'children')
        set(h(1),'linewidth',3);
        set(gca,'fontsize',11,'fontweight','bold');
        set(gca,'linewidth',2)
        set(gca,'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-')
        set(gca,'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'})
        title(strcat(num2str(round(OP.r0*100)),'%Rn'),'fontsize',12);
        %OP.Z0,OP.Zinf%debug
        %if abs(OP.Z0-OP.Zinf)<1.5e-3 set(get(findobj(gca,'type','axes'),'title'),'color','r');end
        if Ib<OP.Ibiasmin set(get(findobj(gca,'type','axes'),'title'),'color','r');end
         
        %set(gca,'xlim',[100 1e5]);
        %set(gca,'ylim',[1e-11 1e-9]);
        %set(gca,'ylim',[1e-18 1e-16]);
        
        %%%Salvar la figura 
        %num2str(gcf) deja de funcionar en matlab2015a
        n=get(gcf,'number');
        fi=strcat('-f',num2str(n));
        mkdir('figs');
        name=strcat('figs\Noise',num2str(Tbath),'mK');
        print(fi,name,'-dpng','-r0');
         
        
%         %%%%Pruebas sobre la cotribución de cada frecuencia a la
%         %%%%Resolucion.
%         if strcmpi(tipo,'nep')&0
%             figure
%             %RESJ=sqrt(2*log(2)./trapz(f,1./medfilt1(totNEP,1).^2));%%%x=noisedata{1}(:,1);
%             RESJ=sqrt(2*log(2)./trapz(f,1./totNEP.^2))
%             %semilogx(f(1:end-1),((RESJ./totNEP(1:end-1)).^2/(2*log(2)).*diff(f))),hold on
%             semilogx(f(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(f))))/1.609e-19),hold on
%             fx=noise{i}(:,1);
%             RESJ2=sqrt(2*log(2)./trapz(fx,1./NEP.^2))
%             %semilogx(fx(1:end-1),((RESJ2./NEP(1:end-1)).^2/(2*log(2)).*diff(fx)),'r')
%             semilogx(fx(1:end-1),sqrt((2*log(2)./cumsum(1./NEP(1:end-1).^2.*diff(fx))))/1.609e-19,'r')
%             %semilogx(fx(1:end-1),((RESJ2./medfilt1(NEP(1:end-1),20)).^2/(2*log(2)).*diff(fx)),'k')
%         end
    end%%%%end_for
else
    
% %     Ib=sscanf(file,strcat(NoiseBaseName,'_%duA*'))*1e-6;
% %     OP=setTESOPfromIb(Ib,IVstr,p);
% % 
% %     hold off;%figure
% %     loglog(noise(:,1),V2I(noise(:,2),circuit),'r'),hold on,grid on,%%%for noise in Current
% %     %loglog(noise(:,1),V2I(noise(:,2),circuit).*OP.V0,'r'),hold on,grid on,%%%for noise in Power
% %     plotnoise('irwin',ZTES,OP,circuit)
end


