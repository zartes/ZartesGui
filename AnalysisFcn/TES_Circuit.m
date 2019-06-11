classdef TES_Circuit
    % Class Circuit for TES data
    %   Circuit represents the electrical components in the TES
    %   characterization.
    
    properties
        Rsh;  %Ohm
        Rf;   %Ohm
        invMf;  % uA/phi
        invMin; % uA/phi        
        L;  % H
        Nsquid; % 'pA/Hz^{0.5}'
%         Rpar;  %Ohm
%         Rn;  % (%)
%         mS;  % Ohm
%         mN;  % Ohm
    end
    
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.Rsh = 0.002;
            obj.Rf = 1e4;
            obj.invMf = 66;
            obj.invMin = 24.1;            
            obj.L = 7.7e-08;
            obj.Nsquid = 3e-12;
%             obj.Rpar = 2.035e-05;
%             obj.Rn = 0.0232;
%             obj.mS = 8133;
%             obj.mN = 650.7;
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
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        if isa(data,'Circuit')
                            eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} '.Value;']);
                        else
                            eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                        end
                    end
                end
                
            end
        end
        
%         function obj = IVcurveSlopesFromData(obj,DataPath,fig)
%             % Function to complete the class with experimental data (Rf, mN and
%             % mS)
%             
%             waitfor(helpdlg('Pick some IV curves to estimate mN (normal state slope) and mS (superconductor state slope)','ZarTES v2.1'));
%             if exist('DataPath','var')
%                 [IVset, pre_Rf] = obj.importIVs(DataPath);
%             else
%                 [IVset, pre_Rf] = obj.importIVs;
%             end
%             if isempty(IVset)
%                 return;
%             end
%             if length(pre_Rf) == 1
%                 obj.Rf = pre_Rf;
%             else
%                 errordlg('Rf values are unconsistent!','ZarTES v2.1')
%                 return;
%             end
%             if exist('fig','var')
%                 [obj.mN, obj.mS] = obj.IVs_Slopes(IVset,fig);
%             else
%                 [obj.mN, obj.mS] = obj.IVs_Slopes(IVset);
%             end
%             obj = obj.RnRparCalc;
%         end
%         
%         function [IVset, pre_Rf] = importIVs(obj,DataPath)
%             % Function to import I-V curve data from files
%             
%             if nargin == 2
%                 [file,path] = uigetfile([DataPath '*'],'Pick a Data path containing IV curves','Multiselect','on');
%             else
%                 [file,path] = uigetfile('G:\Unidades de equipo\ZARTES\DATA\*','Pick a Data path containing IV curves','Multiselect','on');
%             end
%             if iscell(file)||ischar(file)
%                 T = strcat(path,file);
%             else
%                 errordlg('Invalid Data path name!','ZarTES v2.1','modal');
%                 IVset = [];
%                 pre_Rf = [];
%                 return;
%             end
%             wb = waitbar(0,'Please wait...');
%             
%             if (iscell(T))
%                 for i = 1:length(T)
%                     data = importdata(T{i});
%                     if isstruct(data)
%                         data = data.data;
%                     end
%                     
%                     j = size(data,2);
%                     switch j
%                         case 2
%                             auxS.ibias = data(:,1)*1e-6;
%                             if data(1,1) == 0
%                                 auxS.vout = data(:,2)-data(1,2);
%                             else
%                                 auxS.vout = data(:,2)-data(end,2);
%                             end
%                         case 4
%                             auxS.ibias = data(:,2)*1e-6;
%                             if data(1,2) == 0
%                                 auxS.vout = data(:,4)-data(1,4);
%                             else
%                                 auxS.vout = data(:,4)-data(end,4);
%                             end
%                     end
%                     
%                     auxS.Tbath = sscanf(char(regexp(file{i},'\d+.?\d+mK*','match')),'%fmK'); %%%ojo al %d o %0.1f
%                     % Añadido para identificar de donde procede la informacion
%                     auxS.file = file{i};
%                     IVset(i) = auxS;
%                     ind_i = strfind(file{i},'mK_Rf');
%                     ind_f = strfind(file{i},'K_down_');
%                     if isempty(ind_f)
%                         ind_f = strfind(file{i},'K_up_');
%                     end
%                     pre_Rf(i) = str2double(file{i}(ind_i+5:ind_f-1))*1000;
%                     
%                     if ishandle(wb)
%                         waitbar(i/length(T),wb,['Loading IV curves in progress: ' num2str(auxS.Tbath) ' mK']);
%                     end
%                     
%                 end
%                 if ishandle(wb)
%                     delete(wb);
%                 end
%             else
%                 data=importdata(T);
%                 if isstruct(data)
%                     data = data.data;
%                 end
%                 
%                 j = size(data,2);
%                 switch j
%                     case 2
%                         auxS.ibias = data(:,1)*1e-6;
%                         if data(1,1) == 0
%                             auxS.vout = data(:,2)-data(1,2);
%                         else
%                             auxS.vout = data(:,2)-data(end,2);
%                         end
%                     case 4
%                         auxS.ibias = data(:,2)*1e-6;
%                         if data(1,2) == 0
%                             auxS.vout = data(:,4)-data(1,4);
%                         else
%                             auxS.vout = data(:,4)-data(end,4);
%                         end
%                 end
%                 
%                 auxS.Tbath = sscanf(char(regexp(file,'\d+.?\d+mK*','match')),'%fmK')*1e-3; %%%ojo al %d o %0.1f
%                 % Añadido para identificar de donde procede la informacion
%                 auxS.file = file;
%                 IVset = auxS;
%                 ind_i = strfind(file,'mK_Rf');
%                 ind_f = strfind(file,'K_down_');
%                 if isempty(ind_f)
%                     ind_f = strfind(file,'K_up_');
%                 end
%                 pre_Rf = str2double(file(ind_i+5:ind_f-1))*1000;
%                 
%                 
%             end
%             pre_Rf = unique(pre_Rf);
%             if length(pre_Rf) > 1
%                 warndlg('Unconsistency on Rf values, please check it out','ZarTES v2.1');
%             end
%         end
        
%         function [mN, mS] = IVs_Slopes(obj,IVset,fig)
%             % Function to estimate mN and mS from I-V curve data
%             %
%             % The method is based on the derivative I-V curve. There,
%             % variations greater than a tolerance are enough to discard
%             % I-V curve transition phase values. Then, a threshold value
%             % separates data into two clusters. Values greater than
%             % threshold correspond to mS, mS is computed as the median value of
%             % data distribution. Values below the threshold
%             % are related to mN. mN is computed as the
%             % (3er-quartile-median)/2, since distribution is corrupted by
%             % transition phase values that shift the distribution to lower
%             % values. In addition, mN could be computed by a zero cross
%             % linear fitting.
%             
%             if nargin == 1
%                 fig = figure;
%             end
%             ax(1) = subplot(1,2,1);
%             hold(ax(1),'on');
%             grid(ax(1),'on');
%             ax(2) = subplot(1,2,2);
%             hold(ax(2),'on');
%             grid(ax(2),'on');
%             
%             tolerance = 4;
%             
%             for i = 1:length(IVset)
%                 
%                 ibias = IVset(i).ibias;
%                 vout = IVset(i).vout;
%                 
%                 Derv = diff(vout)./diff(ibias);
%                 Dervx = ibias(2:end);
%                 
%                 Diffs = diff(Derv);
%                 Diffsx = ibias(3:end);
%                 ind = find(abs(Diffs) <= tolerance);
%                 
%                 Derivada{i} = Derv(ind);
%                 Derivadax{i} = Dervx(ind);
%                 
%                 ind_erase = find(Derv(ind) <= 0);
%                 Derivada{i}(ind_erase) = [];
%                 ind(ind_erase) = [];
%                 indx{i} = ibias(ind(1:end-1));
%                 indy{i} = vout(ind(1:end-1));
%                 
%                 indxS{i} = ibias(ind(end));
%                 indyS{i} = vout(ind(end));
%                 
%                 if nargin == 3
%                     plot(ax(1),ibias*1e6,vout)
%                     plot(ax(1),ibias(ind+1)*1e6,vout(ind+1),'.r')
%                     
%                     xlabel(ax(1),'I_{bias} (\muA)','fontsize',11,'fontweight','bold');
%                     ylabel(ax(1),'Vout (V)','fontsize',11,'fontweight','bold');
%                     set(ax(1),'fontsize',11,'fontweight','bold');
%                 end
%             end
%             
%             Pendientes = cell2mat(Derivada');
%             MaxP = max(Pendientes);
%             MinP = min(Pendientes);
%             Thres = (MaxP-MinP)/2;
%             
%             mNvalues = Pendientes(Pendientes < Thres);
%             mSvalues = Pendientes(Pendientes > Thres);
%             
%             Values = nan(max(length(mNvalues),length(mSvalues)),2);
%             Values(1:length(mNvalues),1) = mNvalues;
%             Values(1:length(mSvalues),2) = mSvalues;
%             if nargin == 3
%                 boxplot(ax(2),Values);
%                 set(ax(2),'XTick',[1 2],'XTickLabel',{'Normal';'SuperC'})
%                 ylabel(ax(2),'Slopes (V/\muA)','fontsize',11,'fontweight','bold');
%                 set(ax(2),'fontsize',11,'fontweight','bold');
%             end
%             
%             mN1 = (prctile(Pendientes(Pendientes < Thres),75)-median(Pendientes(Pendientes < Thres)))/2+median(Pendientes(Pendientes < Thres));
%             mS = median(Pendientes(Pendientes > Thres));
%             
% %             f = fittype('a*x');
% %             p = polyfit(cell2mat(indx'),cell2mat(indy'),1)
% %             mN = p;
% %             
% %             [fit1,gof,fitinfo] = fit(cell2mat(indx'),cell2mat(indy'),f,'StartPoint',0);
% %             mN = fit1.a;
%             mN = mN1;
%             if nargin == 3
%                 %                 plot(ax(1),sort(unique(cell2mat(indx')))*1e6,sort(unique(cell2mat(indx')))*mN1,'-g')
%                 plot(ax(1),sort(unique(cell2mat(indx')))*1e6,sort(unique(cell2mat(indx')))*mN,'-m')
%             end
%             
%         end
        
%         function obj = RnRparCalc(obj)
%             % Function to compute Rn and Rpar trough the values of the
%             % circuit.
%             
%             obj.Rpar=(obj.Rf*obj.invMf/(obj.mS*obj.invMin)-1)*obj.Rsh;
%             obj.Rn=(obj.Rsh*obj.Rf*obj.invMf/(obj.mN*obj.invMin)-obj.Rsh-obj.Rpar);
%             
%         end
        
    end
end

