classdef TES_Analyzer_Session
    % Class to analyze TES data from one session
    %   Each session open by Analyzer.m is stored in this class.
    
    properties
        File = [];
        Path = [];
        Tag = [];
        TES = [];
        ID = [];
        TES_Idn = [];
        Squid_Idn = [];
        Colddown_Idn = [];
        NickName = [];
        BFieldCond = [];
        Comments = [];
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
                answer = inputdlg({'Insert a Nick name for the TES'},'ZarTES v2.1',[1 50],{' '});               
                if ~isempty(char(answer))
                    answer{1} = filename;
                else
                    answer{1} = 'Default';
                end
                obj.Tag = answer{1};
                tes = load(fullfile(obj.Path, obj.File));
                FN = fieldnames(tes);
                if isa(eval(['tes.' FN{1}]),'TES_Struct')
                    obj.TES = eval(['tes.' FN{1}]);
                else
                    ZTES = eval(['tes.' FN{1} ';']);
                    
                    FieldStr = {'TES';'circuit';'IVset';'IVsetN';'Gset';'GsetN';'IC';'FieldScan';'P';'PN'};
                    FieldNewStr = {'TES';'circuit';'IVsetP';'IVsetN';'GsetP';'GsetN';'PP';'PN'};
                    
                    obj.TES = TES_Struct;
                    obj.TES = obj.TES.Constructor;
                    
                    for i = 1:length(FieldStr)
                        try
                            eval(['obj.TES.' FieldNewStr{i} ' = obj.TES.' FieldNewStr{i} '.Update(ZTES.' FieldStr{i} ');']);
                        catch
                        end
                    end
                    obj.TES.IVsetP.IVsetPath = ZTES.datadir;
                    obj.TES.IVsetN.IVsetPath = ZTES.datadir;
%                     obj.TES.Save([FN{1} '_Compatible.mat']);
                    msgbox({['Analysis corresponding to: ' ZTES.datadir];...
                        'Converting to new struct, some menus may not work properly.'},'ZarTES v2.1');
                end
            end
        end
    end
    
end

