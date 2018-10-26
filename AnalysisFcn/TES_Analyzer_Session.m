classdef TES_Analyzer_Session
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        File = [];
        Path = [];
        Tag = [];
        TES = [];
        ID = [];
    end
    
    methods
        function obj = LoadTES(obj)
            
            [filename, pathname] = uigetfile('*.mat', 'Pick a MATLAB file');
            if isequal(filename,0) || isequal(pathname,0)                
                obj = 0;
            else                
                obj.File = filename;
                obj.Path = pathname;
                answer = inputdlg({'Insert a Nick name for the TES'},'ZarTES v1.0',[1 50],{' '});
                if isempty(answer{1})
                    answer{1} = filename;
                end
                obj.Tag = answer{1};
                tes = load(fullfile(obj.Path, obj.File));
                FN = fieldnames(tes);
                obj.TES = eval(['tes.' FN{1}]);
            end
        end
        
        function obj = Automatic_Analysis(obj)
            
        end
        
    end
    
end

