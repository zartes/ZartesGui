classdef PullPulse 
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        DataUnit = 2;
        infor = [];
        filename
        circuit
        Npulsos
        polarity = 1;
        pulso1
        pulso2
        dc
        dc_std
        pulse_filt
        area
        optArea
        amp
        tmax
        Amax
        rango
        timestamp
        tbath
        rsensor
        L
        SR
        RL
        Ibias
        Ka1 = 5887.65;%maximo Ka1.
        Ka2 = 5898.4;%maximo Ka2.
        OFT_Energy
        indNoise
        indKa
        indKaGood
        indPileLaps
        clustNum        
        indKaNaN
        etiquetas_finales
        Nbin
        eVres

    end

    methods

        function obj = Construction(obj)
            obj.filename = [];
            obj.circuit = [];
            obj.Npulsos = [];
            obj.polarity = 1;
            obj.pulso1 = [];
            obj.pulso2 = [];
            obj.dc = [];
            obj.dc_std = [];
            obj.pulse_filt = [];
            obj.area = [];
            obj.optArea = [];
            obj.amp = [];
            obj.tmax = [];
            obj.Amax = [];
            obj.rango = [];
            obj.timestamp = [];
            obj.tbath = [];
            obj.rsensor = [];
            obj.L = [];
            obj.SR = [];
            obj.RL = [];
            obj.Ibias = [];
            obj.Ka1 = 5887.65;%maximo Ka1.
            obj.Ka2 = 5898.4;%maximo Ka2.
            obj.OFT_Energy = [];
            obj.indNoise = [];
            obj.indKa = [];
            obj.indKaGood = [];
            obj.indPileLaps = [];
            obj.clustNum = [];
            obj.indKaNaN = [];
            obj.etiquetas_finales = [];
            obj.Nbin = [];
            obj.eVres = [];

        end
        function obj = CharacterizeRawPull(obj,file)
            import matlab.io.*
            obj.filename = file;
            obj.infor = fitsinfo(obj.filename);
            obj.Npulsos = obj.infor.BinaryTable(obj.DataUnit-1).Rows;
            obj.L = obj.infor.BinaryTable(obj.DataUnit-1).FieldSize(1);
            fptr = fits.openFile(obj.filename);
            fits.movAbsHDU(fptr,obj.DataUnit);
            obj.SR = str2double(fits.readKey(fptr,'SR'));
            obj.RL = str2double(fits.readKey(fptr,'RL'));
            time=(1:obj.RL)/obj.SR;
            obj.Ibias = str2double(fits.readKey(fptr,'Ibias'));
            Nstep = obj.Npulsos;
            t0ini=0.1;
            optfraction=0.055;
            wfilt = 1;
            topt=t0ini+optfraction;

            %% Lo vamos a hacer de una tacada %%
            raw = fits.readCol(fptr,1,1,Nstep);
            obj.pulso1 = (1:obj.L)/obj.SR;
            obj.pulso2 = (-1)^(obj.polarity+1)*raw;

            obj.dc(1:Nstep)=mean(obj.pulso2(:,1:obj.L*t0ini/2),2);
            obj.dc_std(1:Nstep)=std(obj.pulso2(:,1:obj.L*t0ini/2),0,2);
            obj.pulse_filt = medfilt1(obj.pulso2,wfilt);

            obj.area(1:Nstep)=sum(obj.pulse_filt(:,(obj.L*t0ini-10):end)-obj.dc(1:Nstep)'*ones(1,length((obj.L*t0ini-10):size(obj.pulse_filt,2))),2);

            obj.optArea(1:Nstep)=sum(obj.pulse_filt((obj.L*t0ini-10):obj.L*topt)-obj.dc(1:Nstep)'*ones(1,length((obj.L*t0ini-10):obj.L*topt)),2);

            [maux,miaux]=max(obj.pulse_filt,[],2);

            obj.amp(1:Nstep)=maux-obj.dc(1:Nstep)';
            obj.tmax(1:Nstep)=time(miaux);
            obj.Amax(1:Nstep)=maux;%
            obj.rango(1:Nstep)=range(obj.pulse_filt,2);

            obj.timestamp(1:Nstep)=fits.readCol(fptr,2,1,Nstep);
            obj.tbath(1:Nstep)=fits.readCol(fptr,3,1,Nstep);
            obj.rsensor(1:Nstep)=fits.readCol(fptr,4,1,Nstep);

            fits.closeFile(fptr);

        end

        function obj = DetIndexes(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            options=fitoptions('gauss3');
            options.StartPoint=[100 0.004 1e-4 200 0.39 0.01 50 0.41 0.01];
            options.Lower=zeros(1,9);

            [h,x]=hist(obj.amp,1e4);
            h = double(h);
            x = double(x);
            options.StartPoint=[100 0.004 1e-4 200 0.39 0.01 50 0.41 0.01];
            [~,pos] = findpeaks(h,'MinPeakHeight',10,'MinPeakDistance',100);
            options.StartPoint=[100 x(pos(1)) 1e-4 200 x(pos(2)) 0.01 50 x(pos(3)) 0.01];
            options.TolFun = 1e-9;
            % options=fitoptions('gauss3');
            % options.Lower=zeros(1,9);
            fg = fit(x(:),h(:),'gauss3',options);
            % [B, I] = sort([fg.b1 fg.b2 fg.b3]);


            obj.indNoise=find((obj.amp>fg.b1-2.5*fg.c1) & (obj.amp<fg.b1+2.5*fg.c1));

            obj.indKa=find((obj.amp>fg.b2-2.5*fg.c2) & (obj.amp<fg.b2+2.5*fg.c2));

            % obj.indNoise=find((obj.amp>fg.("b" + num2str(I(1)))-2.5*fg.("c" +num2str(I(1)))) & (obj.amp<fg.("b" +num2str(I(1)))+2.5*fg.("c" +num2str(I(1)))));
            % obj.indKa =find((obj.amp > fg.("b" + num2str(I(2)))-2.5*fg.("c" +num2str(I(2)))) & (obj.amp<fg.("b" +num2str(I(2)))+2.5*fg.("c" +num2str(I(2)))));

            obj.indKaGood = [];
            obj.indKaNaN = obj.indKa;
            obj.indPileLaps = [];
            obj.etiquetas_finales = NaN(1,obj.Npulsos);
            j = 1;
            k = 1;
            k1 = 1;
            for i = obj.indKa
                [pks,locs] = findpeaks(100+obj.pulso2(i,:),'MinPeakHeight',min(100+obj.pulso2(i,:)+0.5*range(100+obj.pulso2(i,:))));
                if length(pks) == 1                   
                    obj.indKaGood(j) = i;
                    obj.indKaNaN(k1) = i;
                    obj.etiquetas_finales(i) = 1;
                    j = j+1;
                    k1 = k1+1;
                else
                    obj.indPileLaps(k) = i;
                    obj.indKaNaN(k1) = NaN;
                    obj.etiquetas_finales(i) = NaN;
                    k = k+1;
                    k1 = k1+1;
                end
            end
            
            
            

        end

        function obj = OFT(obj,OF)

            oftrange = 1:obj.L;
            obj.OFT_Energy(1:obj.Npulsos) = OFTEcalcWjit([obj.pulso1(oftrange); obj.pulso2(:,oftrange)]',OF(oftrange,:));%metemos time en oft tb.

        end

        function plotKapulses(obj)

            str = {'dc';'dc_std';'area';'optArea';'amp';'tmax';'Amax';'OFT_Energy'};
            [s,~] = listdlg('PromptString','Select one parameters:',...
                'SelectionMode','single','ListString',str);
            if isempty(s)
                return;
            end
            featlabel = str{s};     
            if isempty(obj.(featlabel))
                warndlg('No Data available','Analyzer Info...')
                return;
            end

            indices_validos = find(~isnan(obj.etiquetas_finales));
            % indlabel = obj.indKaNaN; 
            % indlabel(isnan(indlabel)) =[];
            figure,
            plot(obj.(featlabel),'.')
            hold on;
            plot(indices_validos,obj.(featlabel)(indices_validos),'.r')
            ylabel(featlabel);
            xlabel('Event (#)');
        end
        function plotNoisepulses(obj)

            str = {'dc';'dc_std';'area';'optArea';'amp';'tmax';'Amax';'OFT_Energy'};
            [s,~] = listdlg('PromptString','Select one parameters:',...
                'SelectionMode','single','ListString',str);
            if isempty(s)
                return;
            end
            featlabel = str{s};  

            indlabel = obj.indNoise;
            figure,
            plot(obj.(featlabel),'.')
            hold on;
            plot(indlabel,obj.(featlabel)(indlabel),'.r')
            ylabel(featlabel);
            xlabel('Event (#)');

        end

            
        function plotDCvalues(obj,featlabel,indlabel)


            figure,
            plot(obj.(featlabel),'.')
            hold on;
            plot(obj.(indlabel),obj.(featlabel)(obj.(indlabel)),'.r')
            ylabel(featlabel);
            xlabel('Event (#)');


        end

        function obj = ClusteringData(obj)

            % inds = obj.indKaNaN;
            % inds(isnan(inds)) = [];
            % Data = obj.dc(inds);
            % eva = evalclusters(Data', 'kmeans', 'Silhouette', 'KList', 1:10);
            % obj.clustNum = eva.OptimalK;
            % obj.clusIndx = kmeans(Data',obj.clustNum);

            % if ~isempty(obj.etiquetas_finales)
            %     indices_validos = find(obj.etiquetas_finales ~= NaN);
            %     if isempty(indices_validos)
            %         warndlg('No clustering is available','Analyzer');
            %         return;
            %     end
            % else
                indices_validos = find(~isnan(obj.etiquetas_finales));
            % end
            datos_dc_validos = obj.dc(indices_validos);
            %% FASE 2: Clusterización de los datos buenos (K = 2)
            % Aplicamos kmeans solo a los datos que superaron el primer filtro

            eva = evalclusters(datos_dc_validos', 'kmeans', 'Silhouette', 'KList', 1:10);
            obj.clustNum = eva.OptimalK;
            [idx_clusters, ~] = kmeans(datos_dc_validos', obj.clustNum);

            % Asignamos las etiquetas de los clusters a sus posiciones originales
            obj.etiquetas_finales(indices_validos) = idx_clusters;

            if ~isempty(obj.clustNum)
                figure, hold on;
                for i = 1:obj.clustNum
                    indices = find(obj.etiquetas_finales==i);
                    plot(indices,obj.dc(indices),'.');                   
                end
                ylabel('dc level');
                xlabel('Event (#)');
                legend;
            end




        end

        function obj = RemoveOutliers_DC(obj,IQR_Factor,clustId)

            if nargin == 3
                datos_crudos = obj.OFT_Energy(:);

                indices_cluster_k = find(obj.etiquetas_finales == clustId);
                datos_cluster_k = datos_crudos(indices_cluster_k);
                Q_local = median(datos_cluster_k);
                % IQR_local = Q_local(2) - Q_local(1);
                limite_inf_local = Q_local - (IQR_Factor * iqr(datos_cluster_k));
                limite_sup_local = Q_local + (IQR_Factor * iqr(datos_cluster_k));

                % 3. Identificar qué datos DE ESTE CLUSTER son outliers
                mascara_outliers_locales = (datos_crudos < limite_inf_local) | (datos_crudos > limite_sup_local);

                % 4. Mapear a los índices originales y marcarlos como NaN (Outliers)
                % indices_outliers_locales = indices_cluster_k(mascara_outliers_locales);
                indices_novalidos = find(mascara_outliers_locales);

                figure
                plot(indices_cluster_k,datos_cluster_k,'.'); hold on;
                [C,ia,ib]=intersect(indices_cluster_k,indices_novalidos);
                plot(indices_cluster_k(ia),datos_cluster_k(ia),'.r')
                ylabel('OFT_{Energy}');
                xlabel('Event (#)');

                answer = questdlg('Do you want to continue?','Analyzer Info...','Yes','No','Yes');
                switch answer

                    case 'Yes'

                        obj.etiquetas_finales(indices_novalidos) = NaN;

                        indices_cluster_k_new = find(obj.etiquetas_finales == clustId);
                        figure
                        plot(indices_cluster_k,datos_cluster_k,'.'); hold on;
                        plot(find(obj.etiquetas_finales == 1),datos_crudos((obj.etiquetas_finales == 1)),'r.');
                        ylabel('OFT_{Energy}');
                        xlabel('Event (#)');
                    otherwise
                        return;
                end

                

            else
                datos_crudos = obj.OFT_Energy(:);
                inds = find(obj.etiquetas_finales == 1);
                % inds = obj.indKaNaN;
                % inds(isnan(inds)) = [];
                datos_Ka = obj.OFT_Energy(find(obj.etiquetas_finales == 1));
                % datos_Ka = obj.dc(obj.indKaNaN); % Aseguramos que sea un vector columna
                IQR_Factor = 3; % Factor habitual para outliers

                if isempty(obj.etiquetas_finales)
                % Array para guardar las etiquetas: NaN = Outlier, 1 = Grupo 1, 2 = Grupo 2
                obj.etiquetas_finales = NaN(size(datos_crudos));
                end

                %% FASE 1: Detección de Outliers Globales
                % Calculamos cuartiles y límites globales
                Q_global = median(datos_Ka);
                % IQR_global = Q_global(2) - Q_global(1);
                limite_inf_global = Q_global - (IQR_Factor * iqr(datos_Ka));
                limite_sup_global = Q_global + (IQR_Factor * iqr(datos_Ka));

                % Identificamos qué datos son VÁLIDOS (no outliers globales)
                mascara_validos_global = (datos_crudos >= limite_inf_global) & (datos_crudos <= limite_sup_global);
                % mascara_novalidos_global = (datos_crudos < limite_inf_global) & (datos_crudos > limite_sup_global);
                % indices_validos = find(mascara_validos_global);
                indices_novalidos = find(~mascara_validos_global);

                figure
                plot(inds,datos_Ka,'.'); hold on;
                [C,ia,ib]=intersect(inds,obj.etiquetas_finales(indices_novalidos));
                plot(inds(ia),datos_Ka(ia),'.r')
                ylabel('OFT_{Energy}');
                xlabel('Event (#)');

                answer = questdlg('Do you want to continue?','Analyzer Info...','Yes','No','Yes');
                switch answer

                    case 'Yes'
                        obj.indKaNaN(indices_novalidos) = NaN;
                        obj.etiquetas_finales(indices_novalidos) = NaN;
                        % obj.etiquetas_finales(indices_validos) = 1;
                        figure
                        plot(inds,datos_Ka,'.'); hold on;
                        plot(find(obj.etiquetas_finales == 1),datos_crudos((obj.etiquetas_finales == 1)),'r.');
                        ylabel('OFT_{Energy}');
                        xlabel('Event (#)');
                        % datos_validos = datos_crudos(indices_validos);
                    otherwise
                        return;
                end

                
            end
            obj.etiquetas_finales(obj.indNoise) = NaN;


        end



        function obj = ResolutionEstimation(obj,clustId,IQR_Factor,NbinSelect)
            nbins = 50:5:500;
            p0=[100 5];
            MnKaHandle=BuildMnKaHandle;
            % options.TolFun = 1e-9;
            options = optimoptions('lsqcurvefit', 'MaxFunctionEvaluations', 200, 'MaxIterations', 500);            

            if clustId == 0
                Data = obj.OFT_Energy;
            else
                if nargin == 3
                    obj = obj.RemoveOutliers_DC(IQR_Factor,clustId);
                end

                indices_cluster_k = find(obj.etiquetas_finales == clustId);
                Data = obj.OFT_Energy(indices_cluster_k);
            end

            if nargin ~= 4
                NbinSelect = 0;
            end

            switch NbinSelect

                case 0  % Automatic

                    Nbin = [];
                    eVres = [];
                    Res = [];
                    j = 1;
                    for i = nbins
                        Nbins = i;
                        try

                            [h,x] = hist(Data,Nbins);
                            h = double(h);
                            x = double(x);
                            f = fit(x(:),h(:),'gauss2');
                            Ka_cal = polyfit([0 f.b2 f.b1],[0 obj.Ka1 obj.Ka2],2);
                            EData = polyval(Ka_cal,Data);

                            [h,x] = hist(EData,Nbins);
                            h = double(h);
                            x = double(x);
                            % f = fit(x(:),h(:),'gauss2');
                            % figure,plot(f,x,h)

                            % Estimación de resolucion
                            [p, resnorm, residual, ~, ~, ~, jacobian] = lsqcurvefit(MnKaHandle,p0,x(:)',h(:)');
                            ci = nlparci(p, residual, 'jacobian', jacobian);
                            error_p = (ci(:,2) - ci(:,1)) / 2;
                            Res(j) = p(2);
                            Error_Res(j) = error_p(2);
                        catch
                        end
                        j = j+1;
                    end

                    if isempty(Res)
                        return;
                    end
                    Res(Res <=1) = NaN;
                    [M, I] = min(Res);
                    Nbin = nbins(I);

                case 1 % Based on Data
                    str = cellstr([{'Freedman-Diaconis'};{'Sturges''s Rule'};{'Scott''s Rule'};{'Square Root''s Rule'}]);
                    [s,~] = listdlg('PromptString','Select Cluster Set:',...
                        'SelectionMode','single',...
                        'ListString',str);


                    n = length(Data);
                    switch s

                        case 1 %'Freedman-Diaconis'
                            iqr_val = iqr(Data);
                            ancho_bin = 2 * iqr_val / (n^(1/3));
                            Nbin = ceil((max(Data) - min(Data)) / ancho_bin);

                        case 2 %'Sturges''s Rule'
                            Nbin = ceil(1 + log2(n));

                        case 3 %'Scott''s Rule'
                            s = std(Data);
                            ancho_bin = 3.49 * s / (n^(1/3));
                            Nbin = ceil((max(Data) - min(Data)) / ancho_bin);

                        case 4 %'Square Root''s Rule'
                            Nbin = ceil(sqrt(length(Data)));

                        otherwise

                            return;

                    end


                case 2 % Manually

                    prompt = {'Enter Nbin value'};
                    name = 'Estimating TES Resolution';
                    numlines = 1;
                    defaultanswer = {'50'};
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    if isempty(answer)
                        warndlg('No value selected',app.version);
                        return;
                    else
                        Nbin = str2double(answer{1});
                        if isnan(Nbin)
                            warndlg('Invalid Nbin value value',app.version);
                            return;
                        end
                    end

            end            
            
            try

            [h,x] = hist(Data,Nbin);
            h = double(h);
            x = double(x);
            f = fit(x(:),h(:),'gauss2');
            Ka_cal = polyfit([0 f.b2 f.b1],[0 obj.Ka1 obj.Ka2],2);
            EData = polyval(Ka_cal,Data);
            [h,x] = hist(EData,Nbin);
            h = double(h);
            x = double(x);
            [p, resnorm, residual, ~, ~, ~, jacobian] = lsqcurvefit(MnKaHandle,p0,x(:),h(:));
            % 2. Calcular el intervalo de confianza al 95% (por defecto)
            ci = nlparci(p, residual, 'jacobian', jacobian);
            % 3. Error absoluto (±) de cada parámetro
            error_p = (ci(:,2) - ci(:,1)) / 2;
            
            obj.eVres = p(2);
            obj.Nbin = Nbin;

            figure
            hist(EData,obj.Nbin);
            grid on
            hold
            E=5875:0.1:5910;%poster Emanuele 5870:5915;
            plot(E,MnKaHandle(p,E),'r','linewidth',3)
            xlim([5875 5910]);
            set(gca,'fontsize',15)
            xlabel('E(eV)')
            title(['Nbins ' num2str(obj.Nbin) ', Ndata ' num2str(length(Data))])
            str=strcat('Fit \Gamma_E =',32,sprintf('%0.2f',p(2)),'±',sprintf('%0.2f',error_p(2)),' eV');
            legend({'K_\alpha data' str},'Location','northwest')

            catch
                errordlg('Some problem occurred','Analyzer Info...');

            end

        end
    
    end

end