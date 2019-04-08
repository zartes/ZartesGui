classdef TES_TFS
    % Class TFS for TES data
    %   This class contains transfer function in superconductor state
    
    properties
        tf;
        re;
        im;
        f;
        file;
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.tf = [];
            obj.re = [];
            obj.im = [];
            obj.f = [];
            obj.file = [];
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i}]))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function obj = UpdateTFS(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                    end
                end
                
            end
        end
        
        function obj = TFfromFile(obj,DataPath,fig)
            % Function to import TF from file
            
            if nargin > 1
                obj1 = obj.importTF(DataPath);
            else
                obj1 = obj.importTF;
            end
            if Filled(obj1)
                obj = obj.UpdateTFS(obj1);
            else
                errordlg('No TF was selected!','ZarTES v1.0')
                return;
            end
            if nargin == 3
                obj = CheckTF(obj,fig);
            else
                obj = CheckTF(obj);
            end
        end
        
        function obj = importTF(obj,DataPath)
            % Function that imports TF from file
            
            if nargin > 1
                [File, path] = uigetfile([DataPath '*TF*'],'Pick Transfer Functions','Multiselect','off');
                if iscell(File)||ischar(File)
                    T = strcat(path, File);
                end
            else
                if ~isempty(obj.file)
                    T = obj.file(1:find(obj.file == filesep,1,'last'));
                else
                    T = 0;
                end
            end
            if ~isequal(T,0)
                data = importdata(T);
                obj.tf = data(:,2)+1i*data(:,3);
                obj.re = data(:,2);
                obj.im = data(:,3);
                obj.f = data(:,1);
                obj.file = T;
            else
                warndlg('No file selected','ZarTES v1.0')
                obj.tf = [];
                obj.re = [];
                obj.im = [];
                obj.f = [];
                obj.file = [];
            end
        end
        
        function obj = PlotTF(obj,fig)
            % Function that visualizes TFS
            
            if nargin < 2
                fig = figure;
            end
            if isempty(obj.tf)
                errordlg('No TF was selected!','ZarTES v1.0');
                obj = TFfromFile(obj,[],fig);
                return;
            end
            ax = axes;
            plot(ax,real(obj.tf),imag(obj.tf),'.','color',[0 0.447 0.741],...
                'markerfacecolor',[0 0.447 0.741],'markersize',15,'DisplayName',obj.file);
            set(ax,'linewidth',2,'fontsize',12,'fontweight','bold');
            xlabel(ax,'Re(mZ)','fontsize',12,'fontweight','bold');
            ylabel(ax,'Im(mZ)','fontsize',12,'fontweight','bold');
            FileName = obj.file(find(obj.file == filesep,1,'last')+1:end);
            title(ax,FileName,'Interpreter','none');
            set(ax,'FontSize',11,'FontWeight','bold');
        end
        
        function obj = CheckTF(obj,fig)
            % Function to check TFS visually
            
            obj.PlotTF(fig);
            ButtonName = questdlg('Is this TFS valid?', ...
                'ZarTES v1.0', ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'No'
                    obj = obj.Constructor;
                case 'Yes'
                    waitfor(msgbox('TF in Superconductor state updated','ZarTES v1.0'));
            end
        end
        
    end
end

