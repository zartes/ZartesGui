classdef TES_ZTDataBase
    % Class Database for TES data
    % Control of Data linking TES with its information regading database
    
    properties
        DataBasePath;
        DataBaseName;
        DBconn;
        TES_Idn;
        MASK_Idn;
        Deposition_Idn;
        Position_Idn;
        Cuarter_Idn;
        Type_Idn;
        SputteringID;
        RTs4p;
        Squid_Idn;
        Colddown_Idn;
        Colddown_Date;        
        BFieldCond;
        Comments;
    end
    properties (Access = private)
        version = 'ZarTES v4.2';
    end
    
    methods
        
        function obj = Constructor(obj,DBName,DBPath)
            % Function to generate the class with default values
            obj.DataBasePath = DBPath;
            obj.DataBaseName = DBName;
            obj.DBconn = database(obj.DataBaseName,'','');
            obj.TES_Idn = [];
            obj.MASK_Idn = [];
            obj.Deposition_Idn = [];
            obj.Position_Idn = [];
            obj.Cuarter_Idn = [];
            obj.Type_Idn = [];
            obj.SputteringID = [];
            obj.RTs4p = [];
            obj.Squid_Idn = [];
            obj.Colddown_Idn = [];
            obj.Colddown_Date = [];
            obj.BFieldCond = [];
            obj.Comments = [];
            
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i} '.Value']))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function [obj, Session] = UpdateFromExcel(obj,Session)
            
            Indx = find(Session.Path(1:end-1) == filesep,3,'last');
            RunStr = Session.Path(Indx(3)+1:end-1);
            % Enlace con el archivo EXCEL
            d = dir([Session.Path(1:find(Session.Path(1:end-1) == filesep,1,'last')) 'Summary*.xls']);
            [~, ~, alltext] = xlsread([Session.Path(1:find(Session.Path(1:end-1) == filesep,1,'last')) filesep d(1).name]);
            
            obj.TES_Idn = alltext{2,3};
            obj.Squid_Idn = alltext{2,2};
            obj.Colddown_Idn = alltext{2,1};   
            obj.Colddown_Date = alltext{2,4};
            
            [~, ~, alltext] = xlsread([Session.Path(1:find(Session.Path(1:end-1) == filesep,1,'last')) filesep d(1).name],2);
            
            RawIndx = str2double(strtok(RunStr,'RUN'))+1;
            obj.BFieldCond = [num2str(alltext{RawIndx,2}) '/' num2str(alltext{RawIndx,3})];  
            obj.Comments = alltext{RawIndx,4};
        end
        
        function [obj, Session] = Update(obj,Session)
            % Function to update the class values
            try
                %if obj.DBconn.MaxDatabaseConnections ~= -1
                sqlquery = ['SELECT * FROM TES_RT WHERE ID_TES = ''' obj.TES_Idn ''''];
                curs1 = exec(obj.DBconn,sqlquery);
                curs1 = fetch(curs1);
                ColNames1 = strsplit(curs1.columnnames,''',''');
                ColNames1{1}(1) = [];
                ColNames1{end}(end) = [];
                if strcmp(curs1.Data,'No Data')
                    waitfor(msgbox('No information of RTs of this TES in the Database yet',obj.version));
                else
                    IndTESRT = find(~cellfun('isempty', strfind(ColNames1,'Location_RT')) == 1);
                    obj.RTs4p = curs1.Data(:,IndTESRT);
                end
                
                obj.MASK_Idn = [obj.TES_Idn(1:strfind(obj.TES_Idn,'Z')-1) 'Z'];
                obj.Deposition_Idn = str2double(obj.TES_Idn(strfind(obj.TES_Idn,'Z')+1:strfind(obj.TES_Idn,'_')-1));
                obj.Position_Idn = str2double(obj.TES_Idn(strfind(obj.TES_Idn,'_')+1:strfind(obj.TES_Idn,'_')+2));
                obj.Type_Idn = obj.TES_Idn(strfind(obj.TES_Idn,'_')+3:end);
                
                % Query a la tabla obleas ID_MASK = '2Z' AND Deposition = 4
                sqlquery = ['SELECT * FROM Wafers WHERE ID_MASK = ''' obj.MASK_Idn...
                    ''' AND Deposition = ' num2str(obj.Deposition_Idn)];
                curs1 = exec(obj.DBconn,sqlquery);
                curs1 = fetch(curs1);
                ColNames1 = strsplit(curs1.columnnames,''',''');
                ColNames1{1}(1) = [];
                ColNames1{end}(end) = [];
                
                IndSpt = find(~cellfun('isempty', strfind(ColNames1,'ID_Sputtering')) == 1);
                obj.SputteringID = curs1.Data{IndSpt};
                
                IndBlt = find(~cellfun('isempty', strfind(ColNames1,'Bilayer_thickness')) == 1);
                [hMo,s] = strtok(curs1.Data{IndBlt},'/');
                Session.TES.TESDim.hMo.Value = str2double(hMo)*1e-9;
                [hAu,s] = strtok(s,'/');
                hAu = str2double(hAu)+str2double(s(2:end));
                Session.TES.TESDim.hAu.Value = hAu*1e-9;
                
                % Query a la tabla masks ID_MASK = '2Z' AND Position = 64 AND
                % Type = 'A'
                sqlquery = ['SELECT * FROM Masks WHERE ID_MASK = '''...
                    obj.MASK_Idn...
                    ''' AND Position = ' num2str(obj.Position_Idn)...
                    ' AND Type = ''' obj.Type_Idn ''''];
                curs2 = exec(obj.DBconn,sqlquery);
                curs2 = fetch(curs2);
                ColNames2 = strsplit(curs2.columnnames,''',''');
                ColNames2{1}(1) = [];
                ColNames2{end}(end) = [];
                
                IndQ = find(~cellfun('isempty', strfind(ColNames2,'Cuarter')) == 1);
                obj.Cuarter_Idn = curs2.Data{IndQ};
                
                sqlquery = ['SELECT * FROM Absorbent WHERE ID_MASK = '''...
                    obj.MASK_Idn...
                    ''' AND Deposition = ' num2str(obj.Deposition_Idn)...
                    ' AND Cuarter = ''' obj.Cuarter_Idn ''''];
                curs3 = exec(obj.DBconn,sqlquery);
                curs3 = fetch(curs3);
                ColNames3 = strsplit(curs3.columnnames,''',''');
                ColNames3{1}(1) = [];
                ColNames3{end}(end) = [];
                
                
                % Presencia de Membrana
                IndMem = find(~cellfun('isempty', strfind(ColNames1,'Membrane')) == 1);
                
                if strcmp(curs1.Data{IndMem},'Yes')
                    Session.TES.TESDim.Membrane_bool = 1;
                    try
                        IndMem_thick = find(~cellfun('isempty', strfind(ColNames1,'Memb_thickness')) == 1);
                        Session.TES.TESDim.Membrane_thick.Value = curs1.Data{IndMem_thick}*1e-6;
                    catch
                    end
                    try
                        IndMemDim = find(~cellfun('isempty', strfind(ColNames2,'Membrane')) == 1);
                        [MemDim1,s] = strtok(curs2.Data{IndMemDim},'x');
                        Session.TES.TESDim.Membrane_length.Value = str2double(MemDim1)*1e-6;
                        Session.TES.TESDim.Membrane_width.Value = str2double(s(2:end))*1e-6;
                    catch
                    end
                else
                    Session.TES.TESDim.Membrane_bool = 0;
                    Session.TES.TESDim.Membrane_thick.Value = 0;
                    Session.TES.TESDim.Membrane_length.Value = 0;
                    Session.TES.TESDim.Membrane_width.Value = 0;
                    
                end
                % Presencia de Absorbente
                IndAbs = find(~cellfun('isempty', strfind(ColNames1,'Absorbent')) == 1);
                
                if strcmp(curs1.Data{IndAbs},'Yes')
                    Session.TES.TESDim.Abs_bool = 1;
                    try
                        IndAbsThick = find(~cellfun('isempty', strfind(ColNames3,'Absorbent_thickness')) == 1);
                        Session.TES.TESDim.Abs_thick.Value = curs3.Data{IndAbsThick}*1e-6;
                    catch
                    end
                    try
                        IndAbsDim = find(~cellfun('isempty', strfind(ColNames2,'Absorbent')) == 1);
                        [AbsDim1,s] = strtok(curs2.Data{IndAbsDim},'x');
                        Session.TES.TESDim.Abs_width.Value = str2double(AbsDim1)*1e-6;
                        Session.TES.TESDim.Abs_length.Value = str2double(s(2:end))*1e-6;
                    catch
                    end
                else
                    Session.TES.TESDim.Abs_bool = 0;
                    Session.TES.TESDim.Abs_thick.Value = 0;
                    Session.TES.TESDim.Abs_width.Value = 0;
                    Session.TES.TESDim.Abs_length.Value = 0;
                end
                
                IndTESD = find(~cellfun('isempty', strfind(ColNames2,'TES_Dim')) == 1);
                
                [Dim1,s] = strtok(curs2.Data{IndTESD},'x');
                Session.TES.TESDim.width.Value = str2double(Dim1)*1e-6;
                Session.TES.TESDim.length.Value = str2double(s(2:end))*1e-6;
                
                sqlquery = ['SELECT * FROM TES_RT WHERE ID_TES = '''...
                    obj.TES_Idn ''''];
                curs4 = exec(obj.DBconn,sqlquery);
                curs4 = fetch(curs4);
                ColNames4 = strsplit(curs4.columnnames,''',''');
                ColNames4{1}(1) = [];
                ColNames4{end}(end) = [];
            end
            
        end
        
    end
end

