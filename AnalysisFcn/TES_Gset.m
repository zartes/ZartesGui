classdef TES_Gset
    % Class Gset for TES data
    %   Data derived from P-Tbath curve fitting at Rn values
    
    properties
        n;      % a.u.
        n_CI;
        K;      % nW/K^n
        K_CI;
        T_fit;     % K
        T_fit_CI;
        G;      % pW/K
        G_CI;
        G100;
        rp;     % Normalized units
        model;
        ERP;    % Normalized units
        R2;     % Determination coefficient
        Tbath;
        Paux;
        Paux_fit;
        opt;
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            n = [];      % a.u.
            n_CI = [];
            K = [];      % nW/K^n
            K_CI = [];
            T_fit = [];     % K
            T_fit_CI = [];
            G = [];      % pW/K
            G_CI = [];
            G100 = [];
            rp = [];     % Normalized units
            model = [];
            ERP = [];    % Normalized units
            R2 = [];     % Determination coefficient            
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        for j = 1:size(data,2)
                            eval(['obj(j).' fieldNames{i} ' = data(j).' fieldNames{i} ';']);
                        end
                    end
                end
                
            end
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for ERP)
            
            FN = properties(obj);
            StrNo = {'ERP'};
            for i = 1:length(FN)
                if isempty(cell2mat(strfind(StrNo,FN{i})))
                    if isempty(eval(['obj.' FN{i}]))
                        ok = 0;  % Empty field
                        return;
                    end
                end
            end
            ok = 1; % All fields are filled
        end
        
        
        function obj = plotNKGT(obj,fig,k,OP)
            % Function to visualize n, K, G and T with respect to RTes/Rn
            %
            % This function allows determining the final thermal
            % parameters, opt is the %Rn to estimate thermal parameters,
            % when empty user can determine the value manually
            
            MS = 5; %#ok<NASGU>
            LS = 1; %#ok<NASGU>
            color{1} = [0 0.447 0.741];
            color{2} = [1 0 0];
            StrField = {'n';'T_fit';'K';'G'};
            StrMultiplier = {'1';'1';'1e9';'1e12';};
            StrLabel = {'n';'T_{fit}(K)';'K(nW/K^n)';'G(pW/K)'};
%             StrRange = {'P';'N'};
            StrIbias = {'Positive';'Negative'};
%             StrIbiasSign = {'+';'-'};
            Marker = {'o';'^'};
            LineStr = {'.-';':'};
            
            if size([obj.n],2) >= 1                                
                
                if nargin < 2
                    fig.hObject = figure;
                else
                    if isempty(fig)
                        fig.hObject = figure;
                    end
                end
                
                if isfield(fig,'subplots')
                    h = fig.subplots;
                end
                for j = 1:length(StrField)
                    if ~isfield(fig,'subplots')
                        h(j) = subplot(2,2,j,'ButtonDownFcn',{@GraphicErrors_NKGT},'LineWidth',2,'FontSize',12,'FontWeight','bold','box','on');
                        hold(h(j),'on');
                        grid(h(j),'on');
                    end
                    rp = [obj.rp];
                    [~,ind] = sort(rp);
                    val = eval(['[obj.' StrField{j} ']*' StrMultiplier{j} ';']);
                    try
                        val_CI = eval(['[obj.' StrField{j} '_CI]*' StrMultiplier{j} ';']);
                        er(j) = errorbar(h(j),eval('rp(ind)'),val(ind),val_CI(ind),'Color',color{k},...
                            'Visible','off','DisplayName',[StrIbias{k} ' Error Bar'],'Clipping','on');
                        set(get(get(er(j),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                    catch
                    end
                    eval(['plot(h(j),rp(ind),val(ind),''' LineStr{k} ''','...
                        '''Color'',''none'',''MarkerEdgeColor'',color{k},''MarkerFaceColor'',color{k},''LineWidth'',LS,''MarkerSize'',MS,''Marker'','...
                        '''' Marker{k} ''',''DisplayName'',''' StrIbias{k} ''');']);
                    xlim(h(j),[0.15 0.9]);
                    xlabel(h(j),'%R_n','FontSize',12,'FontWeight','bold');
                    ylabel(h(j),StrLabel{j},'FontSize',12,'FontWeight','bold');
                    
                    if exist('OP','var')
                        eval(['plot(h(j),rp(OP),obj(OP).' StrField{j} '*' StrMultiplier{j} ',''.-'','...
                            '''Color'',''none'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'',''LineWidth'',LS,''Marker'',''hexagram'',''MarkerSize'',2*MS,''DisplayName'',''Operation Point ' StrIbias{k} ' Ibias'');']);                       
                    end
                    
                end
                fig.subplots = h;
                try
                    data.er = er;
                    set(h,'ButtonDownFcn',{@GraphicErrors_NKGT},'UserData',data)
                catch
                end
                set(h,'Visible','on');
                
            else
                
            end
        end
    
        
        
%           
        
        
    end
end

