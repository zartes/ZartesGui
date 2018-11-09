classdef TES_TFS
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tf;
        re;
        im;
        f;
        file;
    end
    
    methods
        
        function obj = Constructor(obj)
            obj.tf = [];
            obj.re = [];
            obj.im = [];
            obj.f = [];
            obj.file = [];
        end
        
        function obj = UpdateTFS(obj,data)
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
       
        function obj = TFfromFile(obj,DataPath)            
            if exist('DataPath','var')                
                TF = importTF(DataPath);
            else
                if ~isempty(obj.file)
                    PathName = obj.file(1:find(obj.file == filesep,1,'last'));
                    TF = importTF(PathName);
                else
                    TF = importTF;
                end
            end
            if ~isempty(TF)                
                obj = obj.UpdateTFS(TF);
            else
                errordlg('No TF was selected!','ZarTES v1.0')
            end
            obj.PlotTF;
            ButtonName = questdlg('Is this TFS valid?', ...
                'ZarTES v1.0', ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'No'
                    obj = obj.Constructor;                
                case 'Yes'
                    waitfor(msgbox('TF in Superconductor state updated','ZarTES v1.0'));
            end % switch
        end
        
        function obj = PlotTF(obj)
            figure;
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
        
    end    
end

