classdef TES_TF_Opt
    % Class TF for TES data
    %   This class contains options for Z(W) analysis
    
    properties
        boolShow = 1;                               % 0,1
        TFBaseName = '\TF*';                        % \TF*, '\PXI_TF*';
        ElecThermModel = 'One Single Thermal Block' % One Single Thermal Block, Two Thermal Blocks
    end
    
    methods
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_TF_Opt');
            waitfor(Conf_Setup(h,[],obj));
            TF_Opt = guidata(h);
            if ~isempty(TF_Opt)
                obj = obj.Update(TF_Opt);
            end
        end
        
        function obj = Update(obj,data)
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
        
    end
end