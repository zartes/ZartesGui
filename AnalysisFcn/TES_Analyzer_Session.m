classdef TES_Analyzer_Session
    % Class to analyze TES data from one session
    %   Each session open by Analyzer.m is stored in this class.
    
    properties
        File = [];
        Path = [];
        Tag = [];
        TES = [];
        ID = [];        
        NickName = [];
        ZTDB = TES_ZTDataBase;
    end
    
    methods
        function obj = LoadTES(obj)
            % Function to load TES data previously saved.
            H = findobj('Type','Figure','Tag','Analyzer');
            hd = guidata(H);
            [filename, pathname] = uigetfile('*.mat', 'Pick a MATLAB file');
            if isequal(filename,0) || isequal(pathname,0)
                obj = 0;
            else
                obj.File = filename;
                obj.Path = pathname;
                answer = inputdlg({'Insert a Nick name for the TES'},hd.VersionStr,[1 50],{' '});               
                if ~isempty(answer)
                    obj.NickName = answer{1};
                else
                    answer{1} = 'Default';
                    obj.NickName = 'Default';
                end
                obj.Tag = answer{1};
                tes = load(fullfile(obj.Path, obj.File));
%                 if isempty(tes.obj.TESParamP)
%                     rmpath(hd.VersionPath);
%                     addpath([hd.VersionPath(1:find(hd.VersionPath==filesep,1,'last')) 'v2.1']);
%                     pause(2);
%                     tes = load(fullfile(obj.Path, obj.File));
%                 end
                FN = fieldnames(tes);
                if isa(eval(['tes.' FN{1}]),'TES_Struct')
                    %%%%%%%
                    %% Actualización de la estructura a la nueva version
                    obj.TES = TES_Struct;
                    obj.TES = obj.TES.Constructor;
                    %%%%%%%
                    
                    FN = fieldnames(obj.TES);
                    for i = 1:length(FN)
                        try
                            eval(['obj.TES.' FN{i} ' = obj.TES.' FN{i} '.Update(tes.obj.' FN{i} ');']);
                        catch 
                        end
                    end
                    
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
                        'Converting to new struct, some menus may not work properly.'},'ZarTES v2.2');
                end
            end
        end
    end
    
end

