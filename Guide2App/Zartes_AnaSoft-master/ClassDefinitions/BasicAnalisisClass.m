classdef BasicAnalisisClass < handle
    %%%Wrapper Class para encapsular la estructura devuelta por AnalizaRun
    %%%junto con funciones para acceder a la estructura, pintar los datos y
    %%%reanalizarlos.
    properties
        datadir=[];
        structure=[];%%%Estructura global, incluye las IVset, TES, P, etc.
        analizeOptions=[];
        fTES=[];
        fCircuit=[];
        fOperatingPoint=[];
        NoisePlotOptions=BuildNoiseOptions;
        Zfitmodel=[];%%%El modelo con el que se analizaron los datos.
        Zfitboolplot=0;%%%booleano por si quiero pintar o no los resultados del reanálisis.
        
        auxFitstruct=[];%%%Guardo los resultados de reanalisis en una nueva estructura para poder trabajar con ella.
        auxSingleFitStruct=[];
        FitResultsClass;
        
        fGlobalIndex=[];%%%Son los indeces del vector de frecuencias. 1:length()
        mphfitrange=[];
        mjofitrange=[];
        NoiseFilterOptions=[];
        mcmcresult=[];
        mcmcchain=[];
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=BasicAnalisisClass(TES_data_str)
            obj.structure=TES_data_str;
            obj.datadir=TES_data_str.analizeOptions.datadir;
            obj.analizeOptions=TES_data_str.analizeOptions;
            obj.Zfitmodel=TES_data_str.analizeOptions.ZfitOpt.ThermalModel;
            obj.auxFitstruct=TES_data_str.P;%inicializo la auxFitstruct a la estructura original.(para bias positivos).
            obj.fCircuit=obj.structure.circuit;
            obj.fTES=obj.structure.TES;
            obj.NoisePlotOptions.NoiseBaseName=TES_data_str.analizeOptions.ZfitOpt.Noisedata;
%             if strcmp(TES_data_str.analizeOptions.ZfitOpt.Noisedata,'HP')
%                 obj.NoisePlotOptions.NoiseBaseName='\HP_noise*';
%             elseif strcmp(TES_data_str.analizeOptions.ZfitOpt.Noisedata,'PXI')
%                 obj.NoisePlotOptions.NoiseBaseName='\PXI_noise*';
%             end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Plot functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotParameter(obj,Temp,x_str,y_str,varargin)
            %[~,mP]=GetTbathIndex(Temp,obj.structure);
            %paux=obj.structure.P(mP);
            paux=obj.GetPstruct(Temp);
            if nargin==5%%%soreescribimos la P original.
%                 if isstruct(varargin{1})
%                     paux=varargin{1};
%                 else
%                     paux=obj.auxFitstruct;
%                 end
                paux=obj.GetPstruct(Temp,varargin{1});
            end
            plotParamTES(paux,x_str,y_str)
        end
        function plotIVs(obj,Temps,pol)
            %%%plot IVs at Temps and polarity
            data=obj.structure;
            for i=1:length(Temps)
                mIV(i)=GetTbathIndex_IV(Temps(i),data);
                %ivaux=data.IVset(mIV);
            end
            if strcmp(pol,'p')
                plotIVs(obj.fCircuit,data.IVset(mIV));
            elseif strcmp(pol,'n')
                plotIVs(obj.fCircuit,data.IVsetN(mIV));
            end
        end
        function plotZs(obj,Temp,rps,varargin)
            auxstruct=obj.structure;
            polstr='p';
            for i=1:length(varargin)
                if isstruct(varargin{i})
                    paux=obj.GetPstruct(Temp,varargin{1});
                    auxstruct.P=paux;
                end
                if ischar(varargin{i}) polstr=varargin{i};end
            end
            if ~isempty(obj.fGlobalIndex)
                plotZ_Tb_Rp(auxstruct,rps,Temp,obj.fGlobalIndex,polstr);%Para eliminar algunas frecuencias al pintar.
            else
                plotZ_Tb_Rp(auxstruct,rps,Temp,polstr)
            end
        end
        function plotNoises(obj,Temp,rps,varargin)
            actualRps=obj.GetActualRps(Temp,rps);
            auxStr=obj.structure;
            if nargin==4
              auxStr.P=varargin{1};
            end
            noiseoptions=obj.NoisePlotOptions;
            plotnoiseTbathRp(auxStr,Temp,actualRps,noiseoptions)
            if isempty(strfind(obj.NoisePlotOptions.NoiseBaseName,obj.analizeOptions.ZfitOpt.Noisedata))
                warning('OJO: mostrando ruidos distintos a los analizados')
            end
        end
        function plotFunctionFromParameters(obj,Temp,paramList,fhandle,varargin)
            %%%Funcion para pintar una funcion arbitraria de los parametros
            %%%de analisis frente a %Rn.
            
            if nargin==4 %isempty(varargin)
                paux=obj.GetPstruct(Temp);
            else %if nargin==5%%%soreescribimos la P original.
                if isstruct(varargin{1})
                    %'pnew'
                    paux=varargin{1};
                else
                    %'paux'
                    paux=obj.auxFitstruct;
                end
            end
            %paux
            rps=unique([obj.GetPstruct(Temp,paux).p.rp],'stable');%Ojo. GetFunc no devuelve repetidos
            fpar=obj.GetFunctionFromParameters(Temp,paramList,fhandle,paux);
            %size(rps)
            %size(fpar)
            plot(rps(:),fpar(:),'.-','markersize',15,'linewidth',1)
            set(gca,'linewidth',2,'fontsize',12,'fontweight','bold')
            grid on
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Get functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Tc=GetTc(obj)
           Tc=obj.structure.TES.Tc; 
        end
        function Rn=GetRn(obj)
           Rn=obj.structure.TES.Rn; 
        end
        function OP=GetSingleOperatingPoint(obj,Temp,rp,varargin)
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            paux=obj.GetPstruct(Temp,polarity);
            actualRp=obj.GetActualRps(Temp,rp,paux);
            rtes=GetPparam(paux.p,'rp');
            ivaux=obj.GetIV(Temp,polarity);
            Ibias=obj.GetIbias(Temp,actualRp,polarity);
            [~,jj]=min(abs(bsxfun(@minus, rtes', actualRp)));
            jj=unique(jj,'stable');
            opt.model=obj.Zfitmodel;
            param=GetModelParameters(paux.p(jj).parray,ivaux,Ibias,obj.fTES,obj.fCircuit,opt);
            OP=setTESOPfromIb(Ibias,ivaux,param);%setTESOPfromIb
            OP.parray=paux.p(jj).parray;
            obj.fOperatingPoint=OP;
        end
        
        function param=GetFittedParameterByName(obj,Temp,rps,name,varargin)
            if nargin==4%isempty(varargin)
                paux=obj.GetPstruct(Temp);
            else
                if isstruct(varargin{1})
                paux=obj.GetPstruct(Temp,varargin{1});%%%Podemos pasar una nueva estructura P o el auxFitstruct.
                else
                    if ischar(varargin{1})
                        if strcmp(varargin{1},'p')
                            paux=obj.GetPstruct(Temp);
                        elseif strcmp(varargin{1},'n')
                            paux=obj.GetPstruct(Temp,'n');
                        end
                    end
                end
            end
            rtes=GetPparam(paux.p,'rp');
            rps=rps(:)';%%%rps tiene que ser vector fila.
            [~,jj]=min(abs(bsxfun(@minus, rtes', rps)));
            param=GetPparam(paux.p,name);
            %actualRps=rtes(jj)
            actualRps=obj.GetActualRps(Temp,rps,paux);
            jj=unique(jj,'stable');
            param=param(:,jj);%%%Esto devuelve matriz para el p0 y el parray.
        end
        function IV=GetIV(obj,Temp,varargin)
            if nargin==2
                polarity='p';
            elseif nargin==3
                polarity=varargin{1};
            end
            %[mIV,~]=GetTbathIndex(Temp,obj.structure);
            mIV=GetTbathIndex_IV(Temp,obj.structure);
            switch polarity
                case 'p'
                    IV=obj.structure.IVset(mIV);
                case 'n'
                    IV=obj.structure.IVsetN(mIV);
            end
        end
        function P=GetPstruct(obj,Temp,varargin)
            if nargin==3%%%soreescribimos la P original.
                if isstruct(varargin{1})
                    %'pnew'
                    paux=varargin{1};
                else
                    if strcmp(varargin{1},'paux')
                        %'paux'
                        paux=obj.auxFitstruct;
                    elseif strcmp(varargin{1},'p')
                        paux=obj.structure.P;
                    elseif strcmp(varargin{1},'n')
                        paux=obj.structure.PN;
                    end
                end
            else
                %'pold'
                paux=obj.structure.P;
            end
            [~,mP]=GetTbathIndex(Temp,obj.structure.IVset,paux);%%%Usamos el formato en que se pasa IVset y Pset
            P=paux(mP);
            if ~isfield(P.p,'parray')%%%en TES viejos no guardaba parray
                for i=1:length(P.p)
                    P.p(i).parray=[P.p(i).Zinf P.p(i).Z0 P.p(i).taueff];%%%asumimos Irwin 1TB
                end
            end
        end
        function Ibias=GetIbias(obj,Temp,Rp,varargin)
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            IV=obj.GetIV(Temp,polarity);
            Ibias=BuildIbiasFromRp(IV,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
        end
        function Ibiasmin=GetIbiasmin(obj,Temp,varargin)
            %función para devolver el Ibias minimo antes de saltar a
            %superC en las IVs. Normalmente en las Zs el mínimo OP bueno es
            %mayor que eso.
            if nargin==2
                polarity='p';
            elseif nargin==3
                polarity=varargin{1};
            end
            IV=obj.GetIV(Temp,polarity);
            [iaux,ii]=unique(IV.ibias,'stable');
            vaux=IV.vout(ii);
            [~,i3]=min(diff(vaux)./diff(iaux));
            Ibiasmin=iaux(i3);
        end
        function Rpmin=GetRpmin(obj,Temp,varargin)
            %función para devolver el %Rn minimo antes de saltar a
            %superC en las IVs. Normalmente en las Zs el mínimo OP bueno es
            %mayor que eso.
            if nargin==2
                polarity='p';
            elseif nargin==3
                polarity=varargin{1};
            end
            Ibiasmin=obj.GetIbiasmin(Temp,polarity);
            IV=obj.GetIV(Temp,polarity);
            jj=find(abs(IV.ibias)>abs(Ibiasmin));
            Rpmin=spline(IV.ibias(jj),IV.rtes(jj),Ibiasmin);
        end
        function Rlim=Getec51Irwin(obj,Temp,rps,varargin)
            %condicion de estabilidad overdumped.
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            actualrps=obj.GetActualRps(Temp,rps,polarity);
            L0=obj.GetFittedParameterByName(Temp,actualrps,'L0',polarity);
            bi=obj.GetFittedParameterByName(Temp,actualrps,'bi',polarity);
            RL=obj.fCircuit.Rsh+obj.fCircuit.Rpar;
            Rlim=RL*(L0-1)./(L0+1+bi);
        end
        function I0=GetI0(obj,Temp,Rp,varargin)%Corriente del TES en el punto de operacion
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            IV=obj.GetIV(Temp,polarity);
            %Ibias=BuildIbiasFromRp(IV,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
            I0=spline(IV.rtes,IV.ites,Rp);%Ojo, hay que eliminar del spline los Ib<Ibmin.
        end
        function V0=GetV0(obj,Temp,Rp,varargin)%Voltaje del TES en el punto de operacion
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            IV=obj.GetIV(Temp,polarity);
            %Ibias=BuildIbiasFromRp(IV,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
            V0=spline(IV.rtes,IV.vtes,Rp);%Ojo, hay que eliminar del spline los Ib<Ibmin.
                end
        function P0=GetP0(obj,Temp,Rp,varargin)%Potencia del TES en el punto de operacion
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity=varargin{1};
            end
            IV=obj.GetIV(Temp,polarity);
            %Ibias=BuildIbiasFromRp(IV,Rp)*1e-6;%%%Ojo, BuildIbias devuelve uA.
            P0=spline(IV.rtes,IV.ptes,Rp);%Ojo, hay que eliminar del spline los Ib<Ibmin.
        end
        function param=GetParameterFromFit(obj,Temp,Rp,pfit,varargin)
            %%% Si refiteo los datos  de Z(w) necesito recalcular la estructura param
            %%% Función para 1 Rp único. Si no, tendría que pasar también
            %%% pfit como matriz.
                TES=obj.structure.TES;
                Circuit=obj.structure.circuit;
                IVmeasure=obj.GetIV(Temp);
                if nargin==4
                    modelname.model=obj.Zfitmodel;   
                else
                    modelname.model=varargin{1};
                end
                Rpreal=obj.GetActualRps(Temp,Rp);%%%Ojo, yo puedo pasar un %Rn cualquiera, 
                %%%pero no hay datos medidos a todos, así que se busca el %Rn mas cercano al que hay datos
                Ib=BuildIbiasFromRp(IVmeasure,Rpreal)*1e-6;%%%Ojo, BuildIbias devuelve uA.
                %modelname
                param=GetModelParameters(pfit,IVmeasure,Ib,TES,Circuit,modelname);
                OP=setTESOPfromIb(Ib,IVmeasure,param,Circuit);%!pasaba el varargin?!
                obj.fOperatingPoint=OP;
        end
        function Pstruct=BuildNewPstruct(obj,pold,varargin)
            %%%%usamos la funcion GetParameterFromFit para crear una nueva
            %%%%estructura Pstruct a partir de un pold por ejemplo con un
            %%%%nuevo modelo de bloques. Creada para sacar parametros
            %%%%parallel a partir de un fit intermediate por ejemplo
            Temp=pold.Tbath;
            rps=pold.rps;   
            for i=1:length(rps)
                Pstruct.p(i)=obj.GetParameterFromFit(Temp,rps(i),[pold.p(i).parray],varargin{1});
            end
            Pstruct.residuo=pold.residuo;
            Pstruct.rps=obj.GetActualRps(Temp,rps);
            Pstruct.Tbath=Temp;
            
        end
        function fpar=GetFunctionFromParameters(obj,Temp,paramList,fhandle,varargin)
            %%%paramList es un cellarray con los nombres de los parametros
            %%%fhandle es un handle a la definicion de la funcion que se
            %%%quiere ejecutar sobre los parametros. fhandle(p) con
            %%%p_i=p(i,:). Se asumen los rps de la estructura P.
            if nargin==4
                paux=obj.GetPstruct(Temp);
            else
                paux=obj.GetPstruct(Temp,varargin{1});
            end
            rps=[paux.p.rp];
            for i=1:numel(paramList)
                p(i,:)=obj.GetFittedParameterByName(Temp,rps,paramList{i},paux);
            end
            fpar=fhandle(p);
        end
        function actualrps=GetActualRps(obj,Temp,rps,varargin)
            %Devuelve los %Rn más cercanos a los que realmente se tienen
            %datos de Z(w) en la estructura P.
            if nargin==3
                p=obj.GetPstruct(Temp).p;
            else
                p=obj.GetPstruct(Temp,varargin{1}).p;
            end
            rtes=GetPparam(p,'rp');
            rps=rps(:)';%%%rps tiene que ser vector fila.
            [~,jj]=min(abs(bsxfun(@minus, rtes', rps)));
            jj=unique(jj,'stable');%Necesario stable, si no los ordena de menor a mayor independientemente de rps!
            actualrps=rtes(jj);
        end
        function w0=GetwReZcero(obj,Temp,rps,varargin)
            %Funcion para calcular la frecuencia a la que ReZ=0.
            if nargin==3
                Ztes=obj.GetZtesData(Temp,rps);
            else
                Ztes=varargin{1};
            end            
            for i=1:length(rps)
                    if real(Ztes(i).tf(1))<0
                    f0=spline(real(Ztes(i).tf),Ztes(i).f,0);
                    w0(i)=2*pi*f0;
                    %Zinf=-Z0/(taueff*2*pi*f0)^2;
                    else
                        w0(i)=nan;%ReZ=0 sólo si Z0<0.
                    end
            end
        end
        function wmin=Getwmin(obj,Temp,rps,varargin)
            %función para calcular la frecuencia a la que se alcanza el
            %mínimo de ImZ.
            if nargin==3
                Ztes=obj.GetZtesData(Temp,rps);
            else
                Ztes=varargin{1};
            end
            for i=1:length(Ztes)
              [~,fm]=min(imag(Ztes(i).tf));
              wmin(i)=2*pi*Ztes.f(fm);
            end
        end
        function Zfiles=GetZfilenames(obj,Temp,rps,varargin)
            %[mIV,~]=GetTbathIndex(Temp,obj.structure);
            if nargin<=4
                polarity='p';
            else
                polarity=varargin{2};%%%!!!
            end
            ivaux=obj.GetIV(Temp,polarity);
            olddir=pwd;
            %podemos pasar '\PXI_TF_*' para cargar las TF de la PXI. Si se
            %llama obj.GetZfilenames(temp,rps) el nargin sigue siendo 3.
            %%%Ojo, es importante la barra de directorio.
            if nargin==3 
                str='\TF_*'; 
            else
                str=varargin{1};
            end
            cd(obj.datadir)%ojo, GetFilesFromRp solo funciona desde el directorio de datos.
            realRps=obj.GetActualRps(Temp,rps,polarity);
            switch polarity
                case 'p'
                    Zfiles=GetFilesFromRp(ivaux,Temp,realRps,str);
                case 'n'
                    cd('Negative Bias')
                    Zfiles=GetFilesFromRp(ivaux,Temp,realRps,str);
                    cd('..')
            end
            %realRps
            cd(olddir)
        end
        function Ztes=GetZtesData(obj,Temp,rps,varargin)
            if nargin==3
                polarity='p';
                str='\TF_*';
            elseif nargin==4
                str='\TF_*';
                polarity=varargin{1};
            end
            olddir=pwd;
            cd(obj.datadir);
            %%%
            Tdir=GetDirfromTbath(Temp);
            zfiles=obj.GetZfilenames(Temp,rps,str,polarity);
            zfullpath=strcat(Tdir,'\',zfiles);
            switch polarity
                case 'p'
                    tfdata=importTF(zfullpath);
                case 'n'
                    cd('Negative Bias')
                    tfdata=importTF(zfullpath);
                    cd('..')
            end
            %%%hay que hacer buble porque GetZfromTF sólo admite una tf en
            %%%distintos formatos.
            for i=1:numel(tfdata) Ztes(i)=GetZfromTF(tfdata{i},obj.structure.TFS,obj.structure.circuit); end
            %%% devolvemos array de estructuras con las Ztes.
            cd(olddir);
        end
        function Noises=GetNoiseData(obj,Temp,rps,varargin)
            %%%Función que devuelve los ruidos en A/sqrt(Hz) a unos porcentajes concretos
            %%%en un cell array. Se puede pasar '\HP_noise*'(default) o '\PXI_noise*'
            %%%
            olddir=pwd;
            cd(obj.datadir);
            %%%
            circuit=obj.structure.circuit;
            Tdir=GetDirfromTbath(Temp);
            ivaux=obj.GetIV(Temp);
            realRps=obj.GetActualRps(Temp,rps);
            if nargin==3 
                str='\HP_noise*'; 
            else
                if strfind(varargin{1},'HP')
                    str='\HP_noise*';
                elseif strfind(varargin{1},'PXI')
                    str='\PXI_noise*';
                end
            end
            noisefiles=GetFilesFromRp(ivaux,Temp,realRps,str);
           
            Noises=loadnoise(0,Tdir,noisefiles);
            %%%Para devolver directamente el ruido en A/Hz^0.5.
            for i=1:length(Noises)
                Noises{i}(:,2)=V2I(Noises{i}(:,2),circuit);
            end
            cd(olddir);
        end
        function Noises=GetNoiseDataClass(obj,Temp,rps,varargin)
            %%%Same as GetNoiseData, pero devuelve los datos en una Clase
            %%%de tipo NoiseDataClass.
            %%%
            olddir=pwd;
            cd(obj.datadir);
            %%%
            %NoiseBaseName=obj.NoisePlotOptions.NoiseBaseName;
            NoiseBaseName=obj.analizeOptions.ZfitOpt.Noisedata;
            ivaux=obj.GetIV(Temp);
            realRps=obj.GetActualRps(Temp,rps);
            
            %if nargin==3 str='\HP_noise*'; else str=varargin{1};end 
            if nargin==3 
                str=strcat('\',NoiseBaseName,'_noise*');%'\HP_noise*'; 
            else
                if strfind(varargin{1},'HP')
                    str='\HP_noise*';
                elseif strfind(varargin{1},'PXI')
                    str='\PXI_noise*';
                end
            end
            noisefile=GetFilesFromRp(ivaux,Temp,realRps,str);
            Tdir=GetDirfromTbath(Temp);
            fullname=strcat(Tdir,'\',noisefile);
            parameters.TES=obj.fTES;
            parameters.circuit=obj.fCircuit;
            for i=1:length(rps)
                OP=obj.GetSingleOperatingPoint(Temp,rps(i));
                Mjo=obj.GetFittedParameterByName(Temp,rps(i),'M');
                Mph=obj.GetFittedParameterByName(Temp,rps(i),'Mph');%1TB?
                OP.P.M=Mjo;
                OP.P.Mph=Mph;
                parameters.OP=OP;               
                Noises(i)=NoiseDataClass(fullname{i},parameters);
                Noises(i).SetNoiseModel(obj.Zfitmodel);
            end
            cd(olddir);
        end
        function SimModel=GetOPThermalModel(obj,Temp,rps,varargin)
            %%%funcion para devolver el modelo de ruido en unos OPs
            %%%determinados.
            TES=obj.structure.TES;
            circuit=obj.structure.circuit;
            Ib=obj.GetIbias(Temp,rps);
            IV=obj.GetIV(Temp);
            parray=obj.GetFittedParameterByName(Temp,rps,'parray');%acepta varargin. Devuelve parrays en columnas.
            Mjo=obj.GetFittedParameterByName(Temp,rps,'M');
            Mph=obj.GetFittedParameterByName(Temp,rps,'Mph');%1TB?
            if nargin==3
                ThermalModel=obj.analizeOptions.ZfitOpt.ThermalModel;
            else
                ThermalModel=varargin{1};%para extraer otros modelos de ruido en esos puntos de operación
                %%%hay que pasar string.
            end
            for i=1:length(rps)
                opt.model=ThermalModel;
                param=GetModelParameters(parray(:,i)',IV,Ib(i),TES,circuit,opt);%acepta varargin
                OP=setTESOPfromIb(Ib(i),IV,param);
                OP.parray=parray(:,i)';%%%añadido para modelos a 2TB.
                OP.P.M=Mjo(i);
                OP.P.Mph=Mph(i,:);%Funciona si Mph es array?
                parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;%%%movido de L391.
                %model=BuildThermalModel(ThermalModel,parameters);%%%lo estamos llamando 2 veces pq en la primera, OP no está definido.
                %SimNoise{i}=model.noise;%%%%El modelo de ruido se define en BuilThermalModel
                %prueba a definir el modelo de ruido con una clase.
                SimModel(i)=ThermalModelClass(parameters,ThermalModel);
            end%for
            
        end   
        function Taus=GetTaus(obj,Temp,Rp,varargin)
            %%%calcular los taus teoricos del modelo 1TB segun las
            %%%definiciones de Irwin!
            %Ibias=obj.GetIbias(Temp,Rp);
            %ivaux=obj.GetIV(Temp);
            %paux=obj.GetPstruct(Temp);
            circuit=obj.fCircuit;
            RL=circuit.Rsh+circuit.Rpar;
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity='n';
            end
            for i=1:length(Rp)
                OP=obj.GetSingleOperatingPoint(Temp,Rp(i),polarity);
                %Taus=GetTaus(Temp,Ibias,ivaux,paux,obj.fCircuit);
                Req=RL+OP.R0*(1+OP.bi);
                tau_el0=circuit.L./OP.R0;
                beta=(OP.R0-RL)/Req;
                tau_I=OP.tau0/(1-OP.L0);%%%irwin. es igual a nuestro -tau_eff
                tau_el=circuit.L/Req;
                tau_eff=OP.tau0/(1+beta*OP.L0);%%%irwin, no nuestro tau_eff.
                sqr=sqrt((tau_I^-1-tau_el^-1)^2-4*OP.R0*OP.L0*(2+OP.bi)/circuit.L/OP.tau0);
                tau_Mas=2*(tau_I^-1+tau_el^-1+sqr)^-1;
                tau_Menos=2*(tau_I^-1+tau_el^-1-sqr)^-1;
                Taus.tau_I(i)=tau_I;
                Taus.tau_el(i)=tau_el;
                Taus.tau_el0(i)=tau_el0;
                Taus.tau_eff(i)=tau_eff;
                Taus.tau_Mas(i)=tau_Mas;
                Taus.tau_Menos(i)=tau_Menos;
            end
        end
        function A=Get1TBMatrix(obj,Temp,Rp,varargin)
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity='n';
            end
            Ibias=obj.GetIbias(Temp,Rp,polarity);
            ivaux=obj.GetIV(Temp,polarity);
            paux=obj.GetPstruct(Temp,polarity);
            circuit=obj.fCircuit;
            RL=circuit.Rsh+circuit.Rpar;
            Taus=obj.GetTaus(Temp,Rp,polarity);
            %G=obj.structure.TES.G0;
            for i=1:length(Rp)
                OP=obj.GetSingleOperatingPoint(Temp,Rp(i),polarity);
                G=OP.G0;
                %
                C=obj.GetFittedParameterByName(Temp,Rp(i),'C',polarity);%
                A(i,1,1)=1/Taus.tau_el(i);
                A(i,1,2)=OP.L0*G/(OP.I0*circuit.L);
                A(i,2,1)=-(2+OP.bi)*OP.V0/C;
                A(i,2,2)=1/Taus.tau_I(i);
            end
        end
        function Lcriticas=GetLcrit(obj,Temp,rps,varargin)
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity='n';
            end
            TES=obj.fTES;
            RL=obj.fCircuit.Rsh+obj.fCircuit.Rpar;            
            actualrps=obj.GetActualRps(Temp,rps,polarity);
            bi=obj.GetFittedParameterByName(Temp,actualrps,'bi',polarity);
            L0=obj.GetFittedParameterByName(Temp,actualrps,'L0',polarity);
            tau0=obj.GetFittedParameterByName(Temp,actualrps,'tau0',polarity);
            R0=([actualrps]*obj.fCircuit.Rn);
            p1=(3+bi-RL./R0);
            p2=(1+bi+RL./R0);
            sqr=sqrt(L0.*(2+bi).*(L0.*(1-RL./R0)+p2));
            
            Lcritm=(L0.*p1+p2-2*sqr).*R0.*tau0./(L0-1).^2;
            LcritM=(L0.*p1+p2+2*sqr).*R0.*tau0./(L0-1).^2;
            Lcriticas.min=Lcritm;
            Lcriticas.max=LcritM;
            %
            circuit=obj.fCircuit;
            RL=circuit.Rsh+circuit.Rpar;
            Rn=circuit.Rn;
            Req=RL+Rn*actualrps.*(1+bi); %Req=RL+OP.R0*(1+OP.bi);
            taueff=obj.GetFittedParameterByName(Temp,actualrps,'taueff',polarity);
            Lcriticas.underD=taueff.*Req;
        end
        function ec99=Getec99(obj,Temp,rps,varargin)
            %19F25 updated for polarity, but fails.Check.
            if nargin==3
                polarity='p';
            elseif nargin==4
                polarity='n';
            end
            kb=1.38e-23;
            TES=obj.fTES;
            RL=obj.fCircuit.Rsh+obj.fCircuit.Rpar;
            actualrps=obj.GetActualRps(Temp,rps,polarity);
            for i=1:length(actualrps)
                OP=obj.GetSingleOperatingPoint(Temp,actualrps(i),polarity);              
                bi=obj.GetFittedParameterByName(Temp,actualrps(i),'bi',polarity);
                L0=obj.GetFittedParameterByName(Temp,actualrps(i),'L0',polarity);
                tau0=obj.GetFittedParameterByName(Temp,actualrps(i),'tau0',polarity);
                R0=([actualrps(i)]*obj.fCircuit.Rn);
                I0=obj.GetI0(Temp,rps(i),polarity);
                P0=OP.P0;
                T0=obj.structure.TES.Ttes(P0,Temp);%ojo, estamos usando positiva
                SVTES=4*kb*T0*R0*(1+2*bi);
                TL=0.15;%%%ojo, esto puede cambiar.
                SVL=4*kb*TL*RL;
                G0=obj.structure.TES.Gtes(T0);%ojo, estamos usando positiva.
                t=Temp/T0;%Temp=Tbath
                F=(1+t^(TES.n+1))/2;
                %G0=TES.G0;
                SPTFN=4*kb*T0^2*G0*F;               
                ec99(i)=2.355*sqrt(tau0.*I0./L0).*((SPTFN+I0.^2.*SVTES./L0.^2+I0.^2.*(L0-1).^2*SVL./L0.^2).*(SVTES+SVL)).^0.25;
                %ec99(i)=2.355*sqrt(tau0.*I0./L0).*(SPTFN.*SVTES).^0.25;
            end
            ec99=ec99/1.609e-19;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Set functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=SetAuxFitstruct(obj,Pnew)
            obj.auxFitstruct=Pnew;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Fitting functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Pfit=BasicZfit(obj,Temp,rps,varargin)
            modelname=obj.Zfitmodel;
            model=BuildThermalModel(modelname);
            fitfunc=model.function;
            p0=model.X0;
            LB=model.LB;
            UB=model.UB;
            for jj=1:length(Temp)
                actualRps=obj.GetActualRps(Temp(jj),rps);
                ZtesData=GetZtesData(obj,Temp(jj),actualRps);
                fS=ZtesData(1).f;
                ind_all=1:length(fS);%%%De momento cogemos todas las freqs.
                %ind_z=find((fS>5e0 & fS<=40e3) |(fS>40e3 & fS<90e3));%%sobreescribimos ind_z
                ind_z=ind_all(5:9:end);%para seleccionar sólo 1 de cada 9 puntos.
                %ind_z=ind_z([13:19 21:end-13]);%Para eliminar frecuencias extra.
                %ind_z=ind_z(1:end-7);%%%para 62A quitamos tb las ultimas freqs.
                
                p0=obj.GetFittedParameterByName(Temp(jj),actualRps(1),'parray');%empiezo con el parray viejo del primer punto.
                %p0=[p0(1) p0(2) -9.3489e-05 -1.1284 8.2593e-04];%%%data(2)
                p0x=obj.P0Estimate(Temp(jj),actualRps(1));%Estima las taus y K.
                p0(3:5)=p0x(3:5);

            if nargin==4% para jugar con el p0 por ejemplo a un %Rn dado.
                if isnumeric(varargin{1})
                    p0=varargin{1};
                end
                if ischar(varargin{1})
                    newmodel=varargin{1};%pasamos el nombre de un nuevo modelo térmico.
                    modelname=newmodel;
                    model=BuildThermalModel(modelname);
                    fitfunc=model.function;
                    p0=model.X0;
                    LB=model.LB;
                    UB=model.UB;
                end
            end
            
            %p0(3:5)=[1.e-5 0.02 2.6e-5];
            %p0=[0.008   -0.0053   -0.05  -10.0355    1.8512e-05];%1Z10_62A.
            %p0=[0.0130    0.0337   -0.0001   -0.9436    0.0006];%1Z10_62A_down.80%
            %p0=[0.0106   -0.0248   -8.9747e-05   -1.0527   1.9215e-04];%1Z10_62A_down.60%
            %p0=[ 0.0057   -0.0048    4.8e-5    1.7139    0.0024];%1Z10_62B.
            %p0=[0.0152   -0.0114    2.5e-3    0.01    2e-5];%1Z1_54B.
            %p0=[0.0152   -0.0114    5e-5    0.07    2e-4];%1Z1_54B.
            for i=1:numel(ZtesData)
                %ind_z=ind_z(10:end-1*i);%test.falla.habria que llamarla
                %ind_z2.
                filtZ=medfilt1(ZtesData(i).tf,9);%%%promedio cada 9 puntos, ya que hay un artefacto de sampleo.
                %ind_z=ind_all(5:9:end-9*round(actualRps(i)*10));%%%intento de quitar más freqs altas a altos %Rn.
                ind_z=ind_all(5:9:end);
                %ind_z=ind_z([1:end-10]);
                XDATA=ZtesData(i).f(ind_z);                
                %YDATA=medfilt1([real(ZtesData(i).tf(ind_z)) imag(ZtesData(i).tf(ind_z))],1);
                YDATA=[real(filtZ(ind_z)) imag(filtZ(ind_z))];%Seleccionamos el punto central de cada 9.
                p0(1)=YDATA(end,1);p0(2)=YDATA(1,1);
                %p0,pause(1)
                %p0_old=obj.GetFittedParameterByName(Temp(jj),rps(i),'p0');
                %p0=obj.GetFittedParameterByName(Temp(jj),actualRps(i),'parray');%%%Utilizo el p del fit viejo como p0.
                if i>1 p0=obj.auxSingleFitStruct.parray;p0(1)=YDATA(end,1);p0(2)=YDATA(1,1);end%%%Usamos como p0 el p del punto anterior.
                
%                 p0=obj.GetFittedParameterByName(Temp(jj),rps(i),'p0');
                 %p0x=obj.P0Estimate(Temp(jj),rps(i));%Intento de estimacion de tauI, k, tau_1.                 
                 %p0(3:5)=p0x(3:5);
                %p0=[YDATA(1,1) YDATA(1,end) -8.1065e-05 -1.0257 2.5451e-04];
                
%                 %debug1
%                 paux=[0.0151  -0.011386   0.0000211311   0.0526   0.000192];
%                 tt0=[paux(3) paux(5)];
%                 fitaux=@(tt,f)fitfunc([paux(1) paux(2) tt(1) paux(4) tt(2)],f)
%                 [tt,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitaux,tt0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
%                 p=[paux(1) paux(2) tt(1) paux(4) tt(2)]
                %f_debug1
                %%%double_fit
                %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p0,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
                %%%Prueba. refit con pout como nuevo p0.
                %[p,aux1,aux2,aux3,out,aux4,auxJ]=lsqcurvefit(fitfunc,p,XDATA,YDATA,LB,UB);%%%uncomment for real parameters.
                %%%f_double_fit
                            %%%%%%Weighted Fitting Method.            
                            %weight=sqrt((XDATA));                            
                            w=2*pi*XDATA;tI=p0(3);
                            %weight=2*w./(1+(w*tI).^2);%%%Pesamos igualmente cada sector del semicírculo.
                            weight=1;%w.^0.5;
                            costfunction=@(p)weight.*sqrt(sum((fitfunc(p,XDATA)-YDATA).^2,2));
                            [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p0,LB,UB);%%%uncomment for real parameters.
                            n_iter=5;
                            for iter=1:n_iter
                                [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p,LB,UB);%%%uncomment for real parameters.
                            end
                            %%%f_weighted_fit
                ci = nlparci(p,aux2,'jacobian',auxJ);
                resN= aux1;
                %%%Salvamos fit con formato de Estructura
                paux=obj.GetParameterFromFit(Temp(jj),actualRps(i),p,modelname);
                if i==1 Pfit(jj).p=paux;end%%%en la primera iteracion no existe Pfit.
                Pfit(jj).p(i)=Pfit(jj).p(1);%%%después necesitamos crear el siguiente indice antes de llamar a UpdateStruct, si no, no existe.
                Pfit(jj).p(i)=UpdateStruct(Pfit(jj).p(i),paux);%%%paux no contiene p0
                Pfit(jj).p(i).p0=p0;
                Pfit(jj).p(i).w0=obj.GetwReZcero(Temp(jj),actualRps(i),ZtesData(i));
                Pfit(jj).p(i).wmin=obj.Getwmin(Temp(jj),actualRps(i),ZtesData(i));
                Pfit(jj).residuo(i).ci=ci;
                Pfit(jj).residuo(i).resN=resN;
                Pfit(jj).residuo(i).d2=sum(((p0-p)./p0).^2);%%%Suma de diferencias relativas al cuadrado como medida del cambio en 'p'.
                %Pfit(jj).rps(i)=obj.GetActualRps(Temp(jj),rps(i));
                Pfit(jj).rps(i)=actualRps(i);
                if Temp(jj)>1 Pfit(jj).Tbath=Temp(jj)*1e-3; else Pfit(jj).Tbath=Temp(jj);end;
                obj.auxSingleFitStruct=Pfit(jj).p(i);%%%guardamos en esa estructura el resultado de cada fit individual.
                if obj.Zfitboolplot
                    scale=1;
                    %plot(ZtesData(i).tf(ind_z)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    plot(YDATA(:,1)*scale,YDATA(:,2)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    hold on,grid on
                    plot((model.Cfunction(p,XDATA)*scale),'-r')
                    set(gca,'fontsize',12)
                    %figure
                    %semilogx(fS(ind_z),YDATA(:,1),'.-'),hold on
                    %semilogx(fS(ind_z),YDATA(:,2),'.-'),
                end%end_if
            end
            end%end_for_jj
            obj.SetAuxFitstruct(Pfit);%%%<-! Hay que derivar la clase de handle para que funcione!
        end%end_BasicFit
        function p0=P0Estimate(obj,Temp,Rp)
            %%%p0 script for hanging model.
            if strcmp(obj.analizeOptions.ZfitOpt.ThermalModel,'2TB_hanging')
                G0=obj.structure.TES.G0;
                T0=obj.GetTc;
                alfa=50*(1-Rp);
                %P0=1.75e-12;
                %Kp=obj.structure.TES.K;
                %n=obj.structure.TES.n;
                %P0=Kp*T0^n;%%%potencia mínima
                P0=obj.GetP0(Temp,0.5);
                g1t=10*G0;
                Lh=P0*alfa/((G0+g1t)*T0);
                %Lh=0.1;%%0.9 Para el 62B.
                C1=obj.structure.TES.Cabs;
                Ctes=obj.structure.TES.Ctes;
                tau1=C1/g1t;
                tauI=Ctes/(G0*(Lh-1));
                k=g1t/((g1t+G0)*(Lh-1));
                p0=[1 -1 tauI k tau1];
            elseif strcmp(obj.analizeOptions.ZfitOpt.ThermalModel,'2TB_intermediate')
                G0=obj.structure.TES.G0;
                T0=obj.GetTc;
                n=obj.structure.TES.n;
                alfa=50*(1-Rp);
                P0=obj.GetP0(Temp,0.5);
                a=0.5;%g_t1_1/(g_t1_1+g_1b) € (0,1).
                g_t1_0=G0/(1-a);
                LI=P0*alfa/(T0*g_t1_0);
                T1=(a*T0.^n+(1-a)*Temp.^n).^(1./n);
                g_t1_1=g_t1_0*(T1/T0).^(n-1);
                g_1b=g_t1_1*(1-a)/a;
                Ctes=obj.structure.TES.CN;
                C1=0.5*Ctes;%?
                k=a/(LI-1);
                tau1=C1/(g_t1_1+g_1b);
                tauI=Ctes/(g_t1_0*(LI-1));                
                p0=[1 -1 tauI k tau1];
            end
        end
        function RUNDATA=ClassAnalizeRun(obj,varargin)
            if nargin==1
                anaopt=obj.analizeOptions;
            elseif nargin==2
                anaopt=varargin{1};
            end
            RUNDATA=AnalizeRun(anaopt);
        end
        function Pfit=MCMCZfit(obj,Temp,rps,varargin)
            modelname=obj.Zfitmodel;
            model=BuildThermalModel(modelname);
            fitfunc=model.function;
            p0=model.X0;
            LB=model.LB;
            UB=model.UB;
            for jj=1:length(Temp)
                actualRps=obj.GetActualRps(Temp(jj),rps);
                ZtesData=GetZtesData(obj,Temp(jj),actualRps);
                fS=ZtesData(1).f;
                ind_all=1:length(fS);%%%De momento cogemos todas las freqs.                                   
                ind_z=ind_all(5:9:end);%para seleccionar sólo 1 de cada 9 puntos.
          
                p0=obj.GetFittedParameterByName(Temp(jj),actualRps(1),'parray');%empiezo con el parray viejo del primer punto.
                %p0x=obj.P0Estimate(Temp(jj),actualRps(1));%Estima las taus y K.
                %p0(3:5)=p0x(3:5);

            if nargin==4% para jugar con el p0 por ejemplo a un %Rn dado.
                if isnumeric(varargin{1})
                    p0=varargin{1};
                end
                if ischar(varargin{1})
                    newmodel=varargin{1};%pasamos el nombre de un nuevo modelo térmico.
                    modelname=newmodel;
                    model=BuildThermalModel(modelname);
                    fitfunc=model.function;
                    p0=model.X0;
                    LB=model.LB;
                    UB=model.UB;
                end
            end%end_if_nargin
            for i=1:numel(ZtesData)                
                %%%%%%%%%%%%%%Definicion de los datos y parametros
                %%%%%%%%%%%%%%iniciales
                filtZ=medfilt1(ZtesData(i).tf,9);%%%promedio cada 9 puntos, ya que hay un artefacto de sampleo.
                ind_z=ind_all(5:9:end);
                XDATA=ZtesData(i).f(ind_z);                
                %YDATA=medfilt1([real(ZtesData(i).tf(ind_z)) imag(ZtesData(i).tf(ind_z))],1);
                YDATA=[real(filtZ(ind_z)) imag(filtZ(ind_z))];%Seleccionamos el punto central de cada 9.
                p0(1)=YDATA(end,1);p0(2)=YDATA(1,1);
                %p0_old=obj.GetFittedParameterByName(Temp(jj),rps(i),'p0');
                %p0=obj.GetFittedParameterByName(Temp(jj),actualRps(i),'parray');%%%Utilizo el p del fit viejo como p0.
                if i>1 p0=obj.auxSingleFitStruct.parray;p0(1)=YDATA(end,1);p0(2)=YDATA(1,1);end%%%Usamos como p0 el p del punto anterior.
                %%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%First step. LSQ fit para preestimacion de
                %%%%%%%%%%%parametros.
                %%%%%%Weighted Fitting Method.
                %weight=sqrt((XDATA));
                w=2*pi*XDATA;tI=p0(3);
                %weight=2*w./(1+(w*tI).^2);%%%Pesamos igualmente cada sector del semicírculo.
                weight=1;%w.^0.5;
                costfunction=@(p)weight.*sqrt(sum((fitfunc(p,XDATA)-YDATA).^2,2));
                [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p0,LB,UB);%%%uncomment for real parameters.
                n_iter=5;
                for iter=1:n_iter
                    [p,aux1,aux2,aux3,out,aux4,auxJ]=lsqnonlin(costfunction,p,LB,UB);%%%uncomment for real parameters.
                end
                %%%f_weighted_fit
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%MCMC FIT.
                %zinf=0.006955;
                zinf=p0(1);
                %z0=-0.0099;
                z0=p0(2);
                params={
                    {'Zinf',zinf,0,0.1,zinf,0.5e-3}
                    {'Z0',z0,-1,0,z0,0.5e-3}
                    {'taueff',p(3),-1,1,p(3),2e-5}
                    %{'K1',p(4),-Inf,1,p(4),1}
                    %{'tau1',p(5),0,1,p(5),2e-5}
                    %{'K2',p(6),-Inf,1,p(6),0.1}
                    %{'tau2',p(7),0,1,p(7),2e-5}
                    };               
                ssfunction=@(p,ydata)weight.*sqrt(sum((fitfunc(p,XDATA)-ydata).^2,2));
                mcmcmodel.ssfun=ssfunction;%@ssFunct;
                options.nsimu = 100;
                [results, chain, s2chain]= mcmcrun(mcmcmodel,YDATA,params,options);%data
                options.nsimu = 100000;
                options.method  = 'dram';%'mh';%'am';%'dr';%'dram';
                [results, chain, s2chain]= mcmcrun(mcmcmodel,YDATA,params,options,results);
                obj.mcmcresult=results;
                obj.mcmcchain=chain;
                p=results.mean;
                %mcmcplot(chain,[],results,'pairs');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%% Formateamos y pintamos resultados.%%%%%%%%
                ci = nlparci(p,aux2,'jacobian',auxJ);
                resN= aux1;
                %%%Salvamos fit con formato de Estructura
                paux=obj.GetParameterFromFit(Temp(jj),actualRps(i),p);
                if i==1 Pfit(jj).p=paux;end%%%en la primera iteracion no existe Pfit.
                Pfit(jj).p(i)=Pfit(jj).p(1);%%%después necesitamos crear el siguiente indice antes de llamar a UpdateStruct, si no, no existe.
                Pfit(jj).p(i)=UpdateStruct(Pfit(jj).p(i),paux);%%%paux no contiene p0
                Pfit(jj).p(i).p0=p0;
                Pfit(jj).p(i).w0=obj.GetwReZcero(Temp(jj),actualRps(i),ZtesData(i));
                Pfit(jj).p(i).wmin=obj.Getwmin(Temp(jj),actualRps(i),ZtesData(i));
                Pfit(jj).residuo(i).ci=ci;
                Pfit(jj).residuo(i).resN=resN;
                Pfit(jj).residuo(i).d2=sum(((p0-p')./p0).^2);%%%Suma de diferencias relativas al cuadrado como medida del cambio en 'p'.
                %Pfit(jj).rps(i)=obj.GetActualRps(Temp(jj),rps(i));
                Pfit(jj).rps(i)=actualRps(i);
                if Temp(jj)>1 Pfit(jj).Tbath=Temp(jj)*1e-3; else Pfit(jj).Tbath=Temp(jj);end;
                obj.auxSingleFitStruct=Pfit(jj).p(i);%%%guardamos en esa estructura el resultado de cada fit individual.
                if obj.Zfitboolplot
                    scale=1;
                    %plot(ZtesData(i).tf(ind_z)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    plot(YDATA(:,1)*scale,YDATA(:,2)*scale,'.-'),ylabel('ImZ(m\Omega)');xlabel('ReZ(m\Omega)');
                    hold on,grid on
                    plot((model.Cfunction(p,XDATA)*scale),'-r')
                    set(gca,'fontsize',12)
                    %figure
                    %semilogx(fS(ind_z),YDATA(:,1),'.-'),hold on
                    %semilogx(fS(ind_z),YDATA(:,2),'.-'),
                end%end_if_boolplot
            end
            end%end_for_jj
            obj.SetAuxFitstruct(Pfit);
        end
        function NoiseFit(obj,Temp,rps,varargin)
            %%%funcion para jugar con los ajustes de los espectros de ruido
            if nargin==3 
                %HW='\HP_noise*';
                HW=obj.NoisePlotOptions.NoiseBaseName;
            else
                HW=varargin{1};
            end
            if strfind(HW,'HP') HW='\HP_noise*';end
            if strfind(HW,'PXI') HW='\PXI_noise*';end
            TES=obj.structure.TES;
            circuit=obj.structure.circuit;
            
            %%%ojo, solo polaridad positiva.
            for kk=1:length(Temp)
                Noises=obj.GetNoiseData(Temp(kk),rps,HW);
                Ib=obj.GetIbias(Temp(kk),rps);
                IV=obj.GetIV(Temp(kk));
                parray=obj.GetFittedParameterByName(Temp(kk),rps,'parray');%acepta varargin. Devuelve parrays en columnas.
                paux=obj.GetPstruct(Temp(kk));
                %%%
                rtes=GetPparam(paux.p,'rp');
                rps=rps(:)';%%%rps tiene que ser vector fila.
                [~,jj]=min(abs(bsxfun(@minus, rtes', rps)));
                jj=unique(jj,'stable');%Necesario stable, si no los ordena de menor a mayor independientemente de rps!
                %actualrps=rtes(jj);
                %%%
                zaux=obj.GetZtesData(Temp(kk),rps);
                for i=1:length(rps)
                    if isempty(obj.mphfitrange)
                        mphfrange=[2e2,7e2];%%%rango habitual [2e2 1e3].
                    else
                        mphfrange=obj.mphfitrange;
                    end
                    if isempty(obj.mjofitrange)
                        mjofrange=[1e4,10e4];%%%rango habitual [1e4 1e5].
                    else
                        mjofrange=obj.mjofitrange;
                    end
                    if isfield(obj.NoiseFilterOptions,'NoiseSubsampleFreqs')
                        datax=obj.NoiseFilterOptions.NoiseSubsampleFreqs;
                        datay=interp1(Noises{1}(:,1),Noises{1}(:,2),datax);
                    else
                        datax=Noises{1}(:,1);
                        datay=Noises{1}(:,2);
                    end
                    %faux=Noises{1}(:,1);
                    faux=datax;
                    findx=find((faux>mphfrange(1) & faux<mphfrange(2)) | (faux>mjofrange(1) & faux<mjofrange(2)));
                    %xdata=Noises{1}(findx,1);
                    xdata=datax(findx);
                    %size(datax),i
                    
                    %%%Filtramos ruido con NoiseFilterOptions
                    if isempty(obj.NoiseFilterOptions)
                        noisefilteropt.model='movingMean';%%%'minfilt+medfilt';%%%default, medfilt, minfilt,''movingMean'
                        noisefilteropt.wmed=20;
                        noisefilteropt.wmin=6;
                        noisefilteropt.thr=25;
                    else
                        noisefilteropt=obj.NoiseFilterOptions;
                    end
                    obj.NoisePlotOptions.FiltOpt=noisefilteropt;
                    %rps(i)
                    %size(datay(findx))
                    %ydata=filterNoise(1e12*Noises{i}(findx,2),noisefilteropt);%%%
                    ydata=filterNoise(1e12*datay(findx),noisefilteropt);
                    aux.model=obj.Zfitmodel;
                    param=GetModelParameters(parray(:,i)',IV,Ib(i),TES,circuit,aux);%acepta varargin
                    OP=setTESOPfromIb(Ib(i),IV,param);
                    OP.parray=parray(:,i)';%%%añadido para modelos a 2TB.
                    boolusezexp=0;
                    if boolusezexp
                        OP.ztes.data=zaux(i).tf;
                        OP.ztes.freqs=zaux(i).f;
                    end
                    parameters.TES=TES;parameters.OP=OP;parameters.circuit=circuit;
                    noiseaux=noisesim(obj.Zfitmodel,TES,OP,circuit);
                    sI=interp1(noiseaux.f,noiseaux.sI,xdata);
                    nep=sqrt((ydata(:)*1e-12).^2-circuit.squid.^2)./abs(sI(:));
                    m0=[1 1];LB=[0 0];
                    if strcmp(obj.Zfitmodel,'2TB_intermediate') m0=[1 1 1];LB=[0 0 0];end
                    
                    %size(xdata),size(ydata)
                    boolfitcurrent=1;
                    if boolfitcurrent
                        maux=lsqcurvefit(@(x,xdata) fitcurrentnoise(x,xdata,parameters,obj.Zfitmodel),m0,xdata(:),ydata(:),LB);
                    else
                        ydata=nep;%%%ojo, fitjohnson sólo está implementado para usar 'irwin' model.
                        maux=lsqcurvefit(@(x,xdata) fitjohnson(x,xdata,parameters),m0,xdata(:),ydata(:),LB);
                    end
                    maux=real(maux);
                    paux.p(jj(i)).M=maux(end);
                    paux.p(jj(i)).Mph=maux(1);
                    paux.p(jj(i)).Marray=maux;
                    if strcmp(obj.Zfitmodel,'2TB_intermediate') paux.p(jj(i)).Mph2=maux(2);end
                end%for_rps
                %obj.plotNoises(Temp,rps,paux);
                %obj.auxFitstruct=paux;
                obj.auxFitstruct(kk)=paux;
                obj.auxSingleFitStruct=paux;
                if length(Temp)==1 && length(rps)==1
                    obj.plotNoises(Temp,rps,paux)
                    %loglog(datax,datay*1e12,'.-')
                end
            end %end for_kk
        end
        function Results=FitNoiseClass(obj,Temp,rps,varargin)
            if nargin==3 HW='\HP_noise*';else HW=varargin{1};end
            %model=obj.Zfitmodel;
            Noises=obj.GetNoiseDataClass(Temp,rps,HW);
            if strcmp(HW,'\PXI_noise*')
                freqs=logspace(1,5,801);
            else
                freqs=Noises(1).freqs;
            end
            for i=1:length(rps)
                Noises(i).freqs=freqs;
                %Noises(i).SetNoiseModel(model);
                Noises(i).FilterNoise();
                Noises(i).fMphFitRange=[2e3 4e4];
                Noises(i).fMjoFitRange=[2e3 4e4];
                %Podemos cambiar el tipo de ruido0 johnson.
                Noises(i).NoiseModelClass.fJohnsonExcessModel='2F';%%%ojo, esto solo cambia la variable, no el handle.
                Noises(i).NoiseModelClass.GetTotalCurrentNoise();
                Noises(i).FitNoise();
                Results(i)=Noises(i).fOPClass;
            end
            obj.FitResultsClass=Results;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Sim functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [pulso,t]=SimSmallDelta(obj,Temp,rp,varargin)
            %%%Funcion para simular la respuesta del TES en un OP dado a
            %%%una delta con la aprox pequeña señal.
            %%%Impulse(TF) devuelve matriz 2x2. La respuesta 'I'-'P' es el
            %%%elemento (1,2). Luego hay que desplazarlo tini y escalarlo
            %%%por Amp. GetSimPulse implementa lo mismo de otra forma.
            circuit=obj.structure.circuit;
            Rsh=circuit.Rsh;
            Rpar=circuit.Rpar;
            Rn=circuit.Rn;
            L=circuit.L;
            R0=rp*Rn;
            I0=obj.GetI0(Temp,rp);
            bi=obj.GetFittedParameterByName(Temp,rp,'bi');
            tau_el=L/(Rsh+Rpar+R0*(1+bi));
            L0=obj.GetFittedParameterByName(Temp,rp,'L0');
            tau_i=obj.GetFittedParameterByName(Temp,rp,'taueff');
            %G=obj.structure.TES.G;%G cte no reproduce bien las Taus!!!
            OP=obj.GetSingleOperatingPoint(Temp,rp);
            G=OP.G0;
            %C=obj.structure.TES.CN;
            C=obj.GetFittedParameterByName(Temp,rp,'C');
            %C=50e-15;
            A(1,1)=-1/tau_el;
            A(1,2)=-L0*G/(I0*L); %A
            A(2,1)=I0*R0*(2+bi)/C; %B
            A(2,2)=1/tau_i;
            s=tf('s');
            TF=1/(s*eye(2)-A);
            boolplot=0;
            if boolplot
                impulse(TF);
            else
                [pulso,t]=impulse(TF);%Simula bien pulso temporal, pero no tiene en cuenta la amplitud. Usar GetSimPulse!
                pulso=I2V(pulso(:,1,2),obj.fCircuit);
            end
            %[pulso,t]=step(TF);
        end
        function SimPulse=GetSimPulse(obj,Temp,Rp,varargin)
            %similar a SimSmallDelta pero con la i(t) directamente.
            %varargin es opt con t0ini=opt.t0ini, Tend=opt.Tend;
            
            %C=500e-12;%!get
            C=obj.GetFittedParameterByName(Temp,Rp,'C');
            if nargin==3
                t0ini=0.1;%fraccion de trigger.
                Tend=0.04;
                T=[0:1e-6:Tend];
                Energy=6e3*1.609e-19;
            else
                opt=varargin{1};
                t0ini=opt.t0ini;
                Tend=opt.Tend;
                if isfield(opt,'T')
                    T=opt.T;
                else
                    T=[0:1e-6:Tend];
                end
                if isfield(opt,'Energy')
                    Energy=opt.Energy;
                else
                    Energy=5894.4*1.609e-19;
                end
            end
            Taus=obj.GetTaus(Temp,Rp);
            normpulsH=@(p,x)(p(1)/(p(3)-p(2)))*(exp(-(x-p(4))/p(2))-exp(-(x-p(4))/p(3))).*heaviside(x-p(4))+p(5);
            
            tini=t0ini*Tend;
            trise=Taus.tau_Mas;
            tfall=Taus.tau_Menos;
            tI=Taus.tau_I;
            p0=[1 Taus.tau_Mas Taus.tau_Menos tini 0];
            pulse=normpulsH(p0,T);
            pulse(isnan(pulse))=0;
            OP=obj.GetSingleOperatingPoint(Temp,Rp);
            Amp=(1-trise/tI)*(1-tfall/tI)*(1/(2+OP.bi))*(Energy/OP.V0);
            %%%Amp fluctuation attempt DAmp/Amp=(ai/I0)*(dV0/dR0)*(dT0/T0)           
            %Tc=obj.GetTc;
            %DT0=dTperc*Tc;
            ai=OP.ai;
            I0=obj.GetI0(Temp,Rp);
            ivaux=obj.GetIV(Temp);
            dV=diff(ivaux.vtes)./diff(ivaux.Rtes);
            %ind=find(abs(ivaux.rtes-Rp)<0.01);
            %DV0=dV(ind);
            ind=~isnan(dV);
            DV0=interp1(ivaux.rtes(ind),dV(ind),Rp);
            %dTperc=1e-4;%0.5e-6;%0.0001;%dTperc=dT0/T0.
            Tbath=Temp;%ojo, tiene que estar en K.
            if Temp>1 Tbath=1e-3*Temp;end%si pasamos en mK pasamos a K.
            dTbath=1e-6;
            P0=obj.GetP0(Temp,Rp);
            T0=obj.structure.TES.Ttes(P0,Tbath);
            t=Tbath/T0;
            n=obj.fTES.n;
            dTperc=(dTbath/Tbath)*t^n;
            dAperc=(ai/I0)*(DV0)*dTperc;
            AmpR=normrnd(Amp,Amp*dAperc);
            %%%
            boolAmpFluct=0;
            if boolAmpFluct
                Amp=AmpR;
            end
            %disp(Rp)
            %disp(Amp)
            Vpulse=I2V(Amp*pulse,obj.fCircuit);
            %SimPulse=[T(:) Vpulse(:)];
            DT=Energy/C;
            Tpulse=-((1/tI-1/trise)*exp(-(T-tini)/tfall)+(1/tI-1/tfall)*exp(-(T-tini)/trise))*DT/(1/trise-1/tfall).*heaviside(T-tini);
            %SimPulse=[T(:) Tpulse(:)];
            SimPulse.T=T(:);
            SimPulse.Ipulse=Amp*pulse(:);%%%current(I) pulse
            SimPulse.Vpulse=Vpulse(:);%%% Voltage(V) pulse
            SimPulse.Tpulse=Tpulse(:);%%% Temperature (T) pulse.
        end
        function EresData=SimEnergyResolution(obj,Temp,varargin)
            %%%funcion para intentar simular la resolucion a partir de
            %%%pulsos simulados y ruidos simulados. Hay que tomar los rps
            %%%de las medidas.
            paux=obj.GetPstruct(Temp);
            if nargin==2
                rps=[paux.p.rp];
            else
                rps=obj.GetActualRps(Temp,varargin{1});
            end
            for i=1:length(rps)
                SimPulse=obj.GetSimPulse(Temp,rps(i));
                SimNoise=obj.GetOPThermalModel(Temp,rps(i));
                RL=length(SimPulse.T);
                DT=(SimPulse.T(2)-SimPulse.T(1));
                SR=1/DT;
                [~,freqs]=periodogram(SimPulse.Ipulse(:),[],RL,SR,'two-sided');
                fI=SimNoise.GetTotalCurrentNoise();
                MeanNoise=[freqs(:) fI(freqs,0,0)];
                MeanPulse=[SimPulse.T(:) -SimPulse.Ipulse(:)];
                OF=BuildOptimalFilter(MeanPulse,MeanNoise);
                Nsims=1000;
                for j=1:Nsims
                    auxnoise=iPSD((MeanNoise(1:ceil(end/2),2)).^2,MeanNoise(1:ceil(end/2),1));
                    %size(MeanPulse(:,2)),size(auxnoise)
                    auxpulse=MeanPulse(1:length(auxnoise),2)+auxnoise(:);
                    Eest(j)=sum(OF(1:length(auxnoise),2).*auxpulse)*DT;
                end
                [h,x]=hist(Eest,20);
                ft=fit(x(:),h(:),'gauss1');
                %Eres(i)=5894.4*2.355*ft.c1/sqrt(2)/ft.b1;
                EresData(i).Eres=5894.4*2.355*ft.c1/sqrt(2)/ft.b1;
                EresData(i).MeanPulse=MeanPulse;
                EresData(i).MeanNoise=MeanNoise;
                EresData(i).oft=OF;
                EresData(i).Edata=Eest;
                %Eres=Eest;%%%
            end
        end
        
    end %end public methods
end