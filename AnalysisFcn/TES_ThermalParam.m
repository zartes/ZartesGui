classdef TES_ThermalParam
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        n = PhysicalMeasurement;  
        n_CI = PhysicalMeasurement;
        K = PhysicalMeasurement;
        K_CI = PhysicalMeasurement;
        T_fit = PhysicalMeasurement;
        T_fit_CI = PhysicalMeasurement;      
        G = PhysicalMeasurement;
        G_CI = PhysicalMeasurement;
        G100 = PhysicalMeasurement;
        Rn = PhysicalMeasurement;
    end
    properties (Access = private)
        version = 'ZarTES v4.0';
    end
    
    methods
        function obj = Constructor(obj)
            obj.n.Units = 'adim';
            obj.n_CI.Units = 'adim';
            obj.K.Units = 'W/K^n';
            obj.K_CI.Units = 'W/K^n';
            obj.T_fit.Units = 'K';
            obj.T_fit_CI.Units = 'K';
            obj.G.Units = 'W/K';
            obj.G_CI.Units = 'W/K';
            obj.G100.Units = 'W/K';            
            obj.Rn.Units = '%';
            
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        eval(['obj.' fieldNames{i} '.Value = data.' fieldNames{i} '.Value;']);
                    end
                end
                
            end
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for sides)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i} '.Value']))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function CheckValues(obj,CondStr)
            % Function to check visually the class values
            if exist('CondStr','var')
                h = figure('Visible','off','Tag','TES_ThermalParam','Name',CondStr);
            else
                h = figure('Visible','off','Tag','TES_ThermalParam');
            end
            waitfor(Conf_Setup(h,[],obj));
        end
        
        function G_new = G_calc(obj,Temp)
            % Function to compute G at any Temperature in K
            if nargin < 2
                prompt = {'Enter Temp (K) for compute G value'};
                name = 'G(T)';
                numlines = 1;
                defaultanswer = {'0.1'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                if isempty(answer)
                    warndlg('No Temp value selected',obj.version);
                    return;
                else
                    Temp = str2double(answer{1});
                    if isnan(Temp)
                        warndlg('Invalid Temp value',obj.version);
                        return;
                    end
                end
                G_new = obj.n.Value*obj.K.Value*Temp^(obj.n.Value-1);
                uiwait(msgbox(['G(' num2str(Temp) ') = ' num2str(G_new) ' W/K'],obj.version,'modal'));
            end
            try
                G_new = obj.n.Value*obj.K.Value*Temp^(obj.n.Value-1);                
            catch
                disp('TES Thermal Parameter values are empty.')
            end
        end
        
        function obj = SetOperationPoint(obj,Gset,fig,k)
            % Function to set Operation Point on thermal parameters 
            
            if isempty([Gset.n])
                warndlg('TESDATA.fitPvsTset must be firstly applied.',obj.version)
                fig = [];
            end
            MS = 5; %#ok<NASGU>
            LS = 1; %#ok<NASGU>            
            StrField = {'n';'T_fit';'K';'G'};
            TESmult =  {'1';'1';'1e9';'1e12';};
            StrIbias = {'Positive';'Negative'};
            
            IndxOP = findobj('DisplayName',['Operation Point ' StrIbias{k} ' Ibias']);
            delete(IndxOP);
            
            if isfield(fig,'subplots')
                h = fig.subplots;
            end
            
            pause(0.2)
            waitfor(helpdlg('After closing this message, select a point for TES characterization',obj.version));
            figure(fig.hObject);
            
            % Seleccion mediante teclado de la Rn
            prompt = {'Enter the %Rn (0 < %Rn < 1) for TES thermal parameters'};
            name = ['TES Thermal Parameters for ' StrIbias{k} ' Ibias'];
            numlines = 1;
            defaultanswer = {'0.8'};
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if isempty(answer)
                warndlg('No %Rn value selected',obj.version);
                return;
            else
                X = str2double(answer{1});
                if isnan(X)
                    warndlg('Invalid %Rn value',obj.version);
                    return;
                end
            end
            rp = [Gset.rp];
            if X > max(rp)
                X = max(rp);
            end
            
            ind_rp = find(rp >= X ,1); %#ok<NASGU>
            
            
            for i = 1:length(StrField)
                if ~isfield(fig,'subplots')
                    h(i) = subplot(2,2,i,'ButtonDownFcn',{@GraphicErrors_NKGT},'LineWidth',2,'FontSize',12,'FontWeight','bold','box','on');
                    hold(h(i),'on');
                    grid(h(i),'on');
                end
                eval(['val = [Gset.' StrField{i} ']*' TESmult{i} ';']);
                eval(['obj.' StrField{i} '.Value = val(ind_rp);']);
                eval(['val_CI = [Gset.' StrField{i} '_CI]*' TESmult{i} ';']);
                eval(['obj.' StrField{i} '_CI.Value = val_CI(ind_rp);']);
                
                eval(['plot(h(i),Gset(ind_rp).rp,val(ind_rp),''.-'','...
                    '''Color'',''none'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'','...
                    '''LineWidth'',LS,''Marker'',''hexagram'',''MarkerSize'',2*MS,''DisplayName'',[''Operation Point ' StrIbias{k} ' Ibias'']);']);
                axis(h(i),'tight')
                set(h(i),'FontUnits','Normalized');
            end
            obj.K.Value = obj.K.Value*1e-9;
            obj.K_CI.Value = obj.K_CI.Value*1e-9;
            obj.G.Value = obj.G.Value*1e-12;
            obj.G_CI.Value = obj.G_CI.Value*1e-12;
            obj.G100.Value = obj.G_calc(0.1);
            obj.Rn.Value = X;
            
            uiwait(msgbox({['n: ' num2str(obj.n.Value)]; ['K: ' num2str(obj.K.Value*1e9') ' nW/K^n'];...
                ['T_{fit}: ' num2str(obj.T_fit.Value*1e3) ' mK'];['G: ' num2str(obj.G.Value*1e12) ' pW/K']},'TES Operating Point','modal'));
            
        end
                            
        
        
    end
end

