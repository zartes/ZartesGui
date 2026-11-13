classdef NoiseDataClass < handle
    
    properties
        path='';
        file='';
        freqs=logspace(0,6,1000);
        rawVoltage=[];
        CurrentNoise=[];
        NEP=[];%%%El NEP requiere de la sI y por tanto de un modelo.
        fOperatingPoint; %%%field for the OPStruct
        fOPClass; %%%Field for the ModelDependentOperatingPointClass
        fTES;
        fCircuit;
        FilteredVoltageData=[];
        fThermalModelClass=[];
        
        %filter options
        filter_options=[];%.method='movingMean'; %a definir en la funcion filterNoise().
        fMjoFitRange=[1e4 1e5];%%%rango de frecuencias para los fits.
        fMphFitRange=[200 700];
        
        %handles
        fRawVoltageDataHandle=[];
        fCurrentDataHandle=[];
        fNEPHandle=[];
        
        %plotoptions
        plottype='current';%options: 'current', 'nep'
        units='pA';%options: 'pA, fW, A, W' /raizHz.
        boolPlotModel=1;
        boolShowFilteredData=1;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=NoiseDataClass(filename,PARAMETERS)
            circuit=PARAMETERS.circuit;
            if isempty(filename)
                [noise,file,path]=loadnoise(0);
            else
                [noise,file,path]=loadnoise(0,filename);
            end            
            noise=noise{1};
            obj.path=path;
            obj.file=file;
            obj.freqs=noise(:,1);
            obj.rawVoltage=noise(:,2);
            obj.CurrentNoise=V2I(noise(:,2),circuit);
            current=obj.CurrentNoise;
            obj.fRawVoltageDataHandle=@(f) interp1(noise(:,1),noise(:,2),f);
            %obj.fCurrentDataHandle=@(f) interp1(obj.freqs,obj.CurrentNoise,f);
            obj.fCurrentDataHandle=@(f) interp1(noise(:,1),current,f);
            obj.FilteredVoltageData=obj.rawVoltage;%No default filtering.
            obj.fCircuit=circuit;
            obj.fTES=PARAMETERS.TES;
            obj.fOperatingPoint=PARAMETERS.OP;
            
            if length(obj.fOperatingPoint.parray)==3
                obj.SetNoiseModel('default');
            end
            
            obj.filter_options.model='movingMean';
            obj.filter_options.wmed=20;
            obj.filter_options.wmin=5;
            obj.filter_options.thr=25;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Filter Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function filtered_data=FilterNoise(obj,varargin)
            if nargin==1
                filtopt=obj.filter_options;
            else
                filtopt=varargin{1};
            end
            rawData2filter=obj.fRawVoltageDataHandle(obj.freqs);%%% Puedo cambiar freqs para subsamplear por ejemplo.
            filtered_data=filterNoise(rawData2filter,filtopt);
            obj.FilteredVoltageData=filtered_data;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Plot Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Plot(obj)
            %%%Solo pinta modo corriente.
            scale=1;
            if strcmp(obj.units,'pA')
                scale=1e12;
            end
            loglog(obj.freqs,scale*obj.fCurrentDataHandle(obj.freqs),'.-','DisplayName','Current Noise')
%             ch=get(gca,'children');
%             if length(ch)==1
%                 ch.DisplayName='Current Noise'; 
%             end
            grid on
            if obj.boolShowFilteredData
                hold on
                obj.FilterNoise();
                loglog(obj.freqs,scale*V2I(obj.FilteredVoltageData,obj.fCircuit),'.-k','DisplayName','Filtered Noise');
%                 ch=get(gca,'children');
%                 if length(ch)==2
%                     ch(1).DisplayName='Filtered Noise'; 
%                 end
            end
            if obj.boolPlotModel
                hold on
                obj.fThermalModelClass.Plot();
            end
        end
        
        %%%%%%%%%%%%%%%
        %%%Setters
        %%%%%%%%%%%%%%%
        function  SetNoiseModel(obj,model)
            parameters.OP=obj.fOperatingPoint;
            parameters.TES=obj.fTES;
            parameters.circuit=obj.fCircuit;
            parray=obj.fOperatingPoint.parray;
            obj.fThermalModelClass=ThermalModelClass(parameters,model);
            obj.fOPClass=ModelDependentOperatingPointClass(obj.fOperatingPoint,parameters,parray,model);
            obj.fOPClass.fThResolution=obj.fThermalModelClass.fThResolution;
            if isfield(obj.fCircuit,'circuitnoise')
                circuitnoise=obj.fCircuit.circuitnoise;
            else
                circuitnoise=obj.fCircuit.squid;%3e-12;
            end
%             ss=obj.CurrentNoise.^2-circuitnoise.^2;
%             sI=obj.NoiseThermalModelClass.fsIHandel(obj.freqs);
%             obj.NEP=sqrt(ss)./abs(sI);
            
            if isfield(obj.fCircuit,'circuitnoiseHandle')
                cnHandle=obj.fCircuit.circuitnoiseHandle;
            elseif length(circuitnoise==1)
                cnHandle=@(f) circuitnoise;
            else
                cnHandle=@(f) interp1(obj.freqs,circuitnoise,f);
            end
            obj.fNEPHandle=@(f) sqrt(obj.fCurrentDataHandle(f).^2-cnHandle(f).^2)./abs(obj.fThermalModelClass.fsIHandler(f));
            obj.NEP=obj.fNEPHandle(obj.freqs);
            obj.fOPClass.fExResolution=obj.GetBaselineResolution();
        end
        %%%%%%%%%%%%%%%
        %%%Calculations
        %%%%%%%%%%%%%%%
        function Res=GetPartialBaselineResolution(obj,fmax)
            %%%Ojo, para fmax>1e4 da warning de posible falta de precisión.
            %%%ejecuto un for para ver la evolución y tarda bastante. con
            %%%fmax>1e6 da NaN.
            if ~isempty(obj.fNEPHandle)
                fh=@(f) 1./obj.fNEPHandle(f).^2;
                auxint=integral(fh,0,fmax);
                Res=sqrt(2*log(2)./auxint)/1.609e-19;
            else
                ind=find(obj.freqs<fmax);
                Res=sqrt(2*log(2))/sqrt(trapz(obj.freqs(ind),1./obj.NEP(ind).^2))/1.609e-19;%?! if fNEPHandle is empty, NEP also.
            end
            
        end
        function Res=GetBaselineResolution(obj)
            %%%%%%%Experimental Baseline Resolution. Necesita modelo
            %%%%%%%previamente para calcular NEP.
            Res=sqrt(2*log(2))/sqrt(trapz(obj.freqs,1./obj.NEP.^2))/1.609e-19;
        end
        
        %%%%%
        %%% Fit Noise Data
        %%%%%
        function [maux,residual,jacob]=FitNoise(obj)
            %%%%Ajustar el ruido filtrado al modelo fijado previamente.
            if isempty(obj.fThermalModelClass)
                error('Fijar modelo térmico');
            end
            
            FitFunction=obj.fThermalModelClass.fTotalCurrentNoiseModel;
            faux=obj.freqs;          
            findx=find((faux>obj.fMphFitRange(1) & faux<obj.fMphFitRange(2)) | (faux>obj.fMjoFitRange(1) & faux<obj.fMjoFitRange(2)));
            xdata=obj.freqs(findx);
            
            scale=1e12;
            ydata=scale*V2I(obj.FilteredVoltageData(findx),obj.fCircuit);  
            if length(xdata)~=length(ydata)
                error('verify frequency array');
            end
            
            fh=@(x,f)scale*FitFunction(f,x(1),x(2:end));%%%Ajustamos en pA.x(1)=Mjo, x(2:end)=MphArray.
            m0=ones(1,obj.fThermalModelClass.fNumberOfLinks+1);
            LB=zeros(1,obj.fThermalModelClass.fNumberOfLinks+1);
            [maux,R1,residual,~,~,~,jacob]=lsqcurvefit(fh,m0,xdata(:),ydata(:),LB);
            %maux
            %R1
            %residual
            obj.fThermalModelClass.fMjohnson=maux(1);
            obj.fThermalModelClass.fMphononArray=maux(2:end);
            obj.fOPClass.fMjohnson=maux(1);
            obj.fOPClass.fMphononArray=maux(2:end);
        end
    end %%%end methods
end