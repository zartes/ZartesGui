classdef TES_TF_Opt
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        boolShow = 1;
        TFBaseName = '\TF*';% (HP); '\PXI_TF*';
        ElecThermModel = 'One Single Thermal Block'
    end
    
    methods
        function obj = View(obj)
            h = figure('Visible','off','Tag','TES_TF_Opt');
            waitfor(Conf_Setup(h,[],obj));
            TF_Opt = guidata(h);
            if ~isempty(TF_Opt)
                obj = obj.Update(TF_Opt);
            end
        end        
        function obj = Update(obj,data)
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
    end
    
end