classdef TES_Analyzer_Session
    % Class to analyze TES data from one session
    %   Each session open by Analyzer.m is stored in this class.
    
    properties
        File = [];
        Path = [];
        Tag = [];
        TES = [];
        ID = [];
    end
    
    methods
        function obj = LoadTES(obj)
            % Function to load TES data previously saved. 
            
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
    end
    
end

