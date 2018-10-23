function TESDATA = FitZset(TESDATA)
%%%Ajuste automático de Z(w) para varias temperaturas de baño

ButtonName = questdlg('Select Noise Files Acquisition device', ...
    'Noise files', ...
    'PXI', 'HP', 'PXI');
switch ButtonName
    case 'PXI'
        TESDATA.NoiseOpt.NoiseBaseName = '\PXI*';%%%'\HP*'

    case 'HP'
        TESDATA.NoiseOpt.NoiseBaseName = '\HP*';%%%'\HP*'
    otherwise
        disp('PXI acquisition files were selected by default.')
        TESDATA.NoiseOpt.NoiseBaseName = '\PXI*';%%%'\HP*'        
end % switch
%%
%%%definimos variables necesarias.
fS = TESDATA.TFS.f;

StrRange = {'P';'N'};
StrRangeExt = {'Positive Ibias Range';'Negative Ibias Range'};
fig = nan(1,2);
model = 1;

for k1 = 1:2
    if isempty(eval(['TESDATA.IVset' StrRange{k1} '.ibias']))
        continue;
    end
    IVset = eval(['TESDATA.IVset' StrRange{k1}]);
    IVsetPath = IVset(1).IVsetPath;
    if k1 == 1
        indt = find(IVsetPath == filesep);
        IVsetPath = IVsetPath(1:indt(end-1));
        str = dir([IVsetPath '*mK']);
    else
        ind = find(IVsetPath == filesep);
        IVsetPath = [IVsetPath(1:ind(end-1)) 'Negative Bias' filesep];
        str = dir([IVsetPath '*mK']);
    end
    k = 1;
    dirs = {[]};
    for jjj = 1:length(str)
        if str(jjj).isdir
            if isempty(strfind(str(jjj).name,'('))
                dirs{k} = [IVsetPath str(jjj).name];
                k = k+1;
            end
        end
    end        
    h_i = 1;
    h = nan(1,50);
    g = nan(1,50);
    
    H = multiwaitbar(2,[0 0],{'Folder(s)','File(s)'});
    H.figure.Name = 'Z(w) Analysis';
    for i = 1:length(dirs)
        %%%buscamos los ficheros a analizar en cada directorio.
        D = [dirs{i} '\TF*'];
        filesZ = ListInBiasOrder(D);     
        if isempty(filesZ)
            continue;
        end
        D = [dirs{i} TESDATA.NoiseOpt.NoiseBaseName];
        filesNoise = ListInBiasOrder(D);
        %%%buscamos la IV correspondiente a la Tmc dada
        
        Path = dirs{i}(find(dirs{i} == filesep, 1, 'last' )+1:end);
        Tbath = sscanf(Path,'%dmK');                
        [~,Tind] = min(abs([IVset.Tbath]*1e3-Tbath));
        %%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
        IV = IVset(Tind);
        
        %%%hacemos loop en cada fichero a analizar.
        k = 1;
        ImZmin = nan(1,length(filesZ));
        jj = 1;
        for j1 = 1:length(filesZ)
            NameStr = filesZ{j1};
            NameStr(NameStr == '_') = ' ';
            if ishandle(H.figure)
                multiwaitbar(2,[i/length(dirs) j1/length(filesZ)],{Path,NameStr},H);
            else
                H = multiwaitbar(2,[i/length(dirs) j1/length(filesZ)],{Path,NameStr});
                H.figure.Name = 'ZarTES v1.0';
            end
            thefile = strcat(dirs{i},'\',filesZ{j1});
            Ib = sscanf(char(regexp(thefile,'-?\d+.?\d+uA','match')),'%fuA')*1e-6;
            if isempty(Ib)&&~isempty(strfind(thefile,'_0uA.txt'))
                Ib = 0;
            end
            %%%importamos la TF
            data = importdata(thefile);
            tf = data(:,2)+1i*data(:,3);
            Rth = TESDATA.circuit.Rsh+TESDATA.circuit.Rpar+2*pi*TESDATA.circuit.L*data(:,1)*1i;
            ztes = (TESDATA.TFS.tf./tf-1).*Rth;
            Zinf = real(ztes(end));
            Z0 = real(ztes(1));
            tau0 = 1e-4;
            opts = optimset('Display','off');
            switch model
                case 1
                    p0 = [Zinf Z0 tau0];          % 3 parameters      
                    StrModel = 'One Single Thermal Block'; %#ok<NASGU>
                case 2
                    ca0 = 1e-1;
                    tauA = 1e-6;                    
                    p0=[Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                    StrModel = 'Two Thermal Blocks (Specify which)'; %#ok<NASGU>
                case 3
                    tau1 = 1e-5;
                    tau2 = 1e-5;
                    d1 = 0.8;
                    d2 = 0.1;
                    p0=[Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.   % 7 parameters
                    StrModel = 'Three Thermal Blocks (Specify which)'; %#ok<NASGU>
            end
            
            [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@fitZ,p0,fS,...
                [real(ztes) imag(ztes)],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
            MSE = (aux2'*aux2)/(length(fS)-length(p)); %#ok<NASGU>
            ci = nlparci(p,aux2,'jacobian',jacob);
            CI = ci'-p;
            CI = abs(CI(1,:)).*sign(p); 
            p_CI = [p; CI];
            param = GetModelParameters(p_CI,IV,Ib,TESDATA);
            if param.rp > 1 || param.rp < 0
                continue;
            end
            paramList = fieldnames(param);
            for pm = 1:length(paramList)
                eval(['TESDATA.P' StrRange{k1} '(i).p(jj).' paramList{pm} ' = param.' paramList{pm} ';']);
            end
            eval(['TESDATA.P' StrRange{k1} '(i).CI{jj} = CI;']);  
            eval(['TESDATA.P' StrRange{k1} '(i).residuo(jj) = aux1;']);
            eval(['TESDATA.P' StrRange{k1} '(i).fileZ(jj) = {[dirs{i} filesep filesZ{j1}]};']);  
            eval(['TESDATA.P' StrRange{k1} '(i).ElecThermModel(jj) = {StrModel};']);  
            
                                 
            %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
            boolShow = 1;
            if boolShow
                if jj == 1
                    fig(i) = figure('Name',Path);
                    ax = axes;
                end
                ind = 1:3:length(ztes);
                                
                h(h_i) = plot(ax,1e3*ztes(ind),'.','color',[0 0.447 0.741],...
                    'markerfacecolor',[0 0.447 0.741],'markersize',15,'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj}]);
                grid(ax,'on');
                hold(ax,'on');%%% Paso marker de 'o' a '.'
                set(ax,'linewidth',2,'fontsize',12,'fontweight','bold');
                xlabel(ax,'Re(mZ)','fontsize',12,'fontweight','bold');
                ylabel(ax,'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                ImZmin(jj) = min(imag(1e3*ztes));
                ylim(ax,[min(-15,min(ImZmin)-1) 1])
                fZ = fitZ(p,fS);
                g(h_i) = plot(ax,1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2,...
                    'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj} ':fit']);hold(ax,'on');
                
                set([h(h_i) g(h_i)],'UserData',[h(h_i) g(h_i)]);
                
                eval(['TESDATA.P' StrRange{k1} '(i).ztes{jj} = ztes;']);
                eval(['TESDATA.P' StrRange{k1} '(i).fZ{jj} = fZ;']);                                
                
                if k == 1 || jj == length(filesZ)
                    aux_str = strcat(num2str(round(param.rp*100)),'% R_n'); %#ok<NASGU>
                end
                k = k+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%Analizamos el ruido
            if ~isempty(filesNoise)
                if i == 1 && j1 == 1
                    H1 = multiwaitbar(2,[0 0],{Path,NameStr});
                    H1.figure.Name = 'Noise Analysis';
                end
                NameStr = filesNoise{j1};
                NameStr(NameStr == '_') = ' ';
                if ishandle(H1.figure)
                    multiwaitbar(2,[i/length(dirs) j1/length(filesNoise)],{Path,NameStr},H1);
                else
                    H1 = multiwaitbar(2,[i/length(dirs) j1/length(filesNoise)],{Path,NameStr});
                    H1.figure.Name = 'Noise Analysis';
                end
                [noisedata, file] = loadnoise(0,dirs{i},filesNoise{j1});%#ok<ASGLU> %%%quito '.txt'
                OP = setTESOPfromIb(Ib,IV,param);
                noiseIrwin = noisesim('irwin',TESDATA.TES,OP,TESDATA.circuit);
                f = logspace(0,6,1000);
                sIaux = ppval(spline(f,noiseIrwin.sI),noisedata{1}(:,1));
                NEP = sqrt(V2I(noisedata{1}(:,2),TESDATA.circuit).^2-noiseIrwin.squid.^2)./sIaux;
                NEP = NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.
                
                RES = 2.35/sqrt(trapz(noisedata{1}(1:size(NEP,1),1),1./medfilt1(real(NEP),20).^2))/2/1.609e-19; %#ok<NASGU>
%                 RES = 2.35/sqrt(trapz(noisedata{1}(1:end-1,1),1./medfilt1(real(NEP),20).^2))/2/1.609e-19; %#ok<NASGU>
                
                eval(['TESDATA.P' StrRange{k1} '(i).p(jj).ExRes = RES;']);
                eval(['TESDATA.P' StrRange{k1} '(i).p(jj).ThRes = noiseIrwin.Res;']);
                eval(['TESDATA.P' StrRange{k1} '(i).fileNoise(jj) = {[dirs{i} filesep filesNoise{j1}]};']);
                eval(['TESDATA.P' StrRange{k1} '(i).NoiseModel(jj) = {''Irwin Model''};']);
                
                
                
                %%%Excess noise trials.
                %%%Johnson Excess
                findx = find(noisedata{1}(:,1) > TESDATA.JohnsonExcess(1) & noisedata{1}(:,1) < TESDATA.JohnsonExcess(1));
                xdata = noisedata{1}(findx,1); %#ok<NASGU>
                %ydata=sqrt(V2I(noisedata{1}(findx,2),circuit.Rf).^2-noiseIrwin.squid.^2);
                ydata = medfilt1(real(NEP(findx))*1e18,20);
                %size(ydata)
                if sum(ydata == Inf) %%%1Z1_23A @70mK 1er punto da error.
                    eval(['TESDATA.P' StrRange{k1} '(i).p(jj).M = 0;']);
                else                    
                    eval(['TESDATA.P' StrRange{k1} '(i).p(jj).M = lsqcurvefit(@(x,xdata) fitnoise(x,xdata,TESDATA.TES,OP,TESDATA.circuit),0,xdata,ydata,[],[],optimset(''Display'',''off''));']);                    
                end
                %%%phonon Excess
                findx = find(noisedata{1}(:,1) > TESDATA.PhononExcess(1) & noisedata{1}(:,1) < TESDATA.PhononExcess(2));
                ydata = median(real(NEP(findx))*1e18);
                if sum(ydata == inf)
                    eval(['TESDATA.P' StrRange{k1} '(i).p(jj).Mph = 0;']);
                else
                    ymod = median(ppval(spline(f,noiseIrwin.NEP*1e18),noisedata{1}(findx,1))); %#ok<NASGU>
                    eval(['TESDATA.P' StrRange{k1} '(i).p(jj).Mph = sqrt(ydata/ymod-1);']);
                end                
            end
            h_i = h_i+1;
            jj = jj+1;
        end
        eval(['TESDATA.P' StrRange{k1} '(i).Tbath = Tbath*1e-3;;']);
        
    end
    eval(['dat.P = TESDATA.P' StrRange{k1} ';']);
    dat.fig = fig;
    set(fig,'UserData',dat);
    if ishandle(H.figure)
        delete(H.figure)
        clear('H')
    end
    if ishandle(H1.figure)
        delete(H1.figure)
        clear('H1')
    end    
    
    pause(0.2)
    waitfor(helpdlg('After closing this message, check the validity of the curves and fittings','ZarTES v1.0'));
    Data = get(fig(1),'UserData'); %#ok<NASGU>
    eval(['TESDATA.P' StrRange{k1} ' = Data.P;']);
    
    % Capar los datos de forma que no puedan existir valores porl
    % encima de 1 y por debajo de 0
    % Además tendríamos que hacer un sort para que se pinten en
    % orden ascendente
    eval(['a = cell2mat(TESDATA.P' StrRange{k1} '(k1).CI)'';']);
    eval(['[rp,rpjj] =sort([TESDATA.P' StrRange{k1} '(k1).p.rp]);']);
    
    switch model
        case 1
            StrModelPar = {'Zinf';'Z0';'taueff'};          % 3 parameters
        case 2
            StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};               
        case 3     
            StrModelPar = {'Zinf';'Z0';'taueff';'tau1';'tau2';'d1';'d2'}; 
    end
    figParam(k1) = figure; %#ok<AGROW>
    as = nan(1,length(StrModelPar));
    for i = 1:length(StrModelPar)
        as(i) = subplot(1,length(StrModelPar),i);
        eval(['errorbar(as(i),rp,[TESDATA.P' StrRange{k1} '(k1).p(rpjj).' StrModelPar{i} '],'...
            'a(rpjj,1),''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
        xlabel(as(i),'R_{TES}/R_n','fontsize',12,'fontweight','bold');
        ylabel(as(i),StrModelPar{i},'fontsize',12,'fontweight','bold');
        grid(as(i),'on');
        hold(as(i),'on');
    end
    set(as,'linewidth',2,'fontsize',12,'fontweight','bold');
    figParam(k1).Name = ['Thermal Model Parameters Evolution: ' StrRangeExt{k1}]; %#ok<AGROW>
    
%             figure,errorbar([TESDATA.PP(k1).p.rp],[TESDATA.PP(k1).p.Z0],a(:,2))
%             figure,errorbar([TESDATA.PP(k1).p.rp],[TESDATA.PP(k1).p.taueff],a(:,3))
end

