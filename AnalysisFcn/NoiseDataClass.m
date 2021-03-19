classdef NoiseDataClass < handle
    
    properties
        path='';
        file='';
        freqs=logspace(0,6,1000);
        rawVoltage=[];
        CurrentNoise=[];
        NEP=[];%%%El NEP requiere de la sI y por tanto de un modelo.
        fOperatingPoint;
        fTES;
        fCircuit;
        FilteredVoltageData=[];
        NoiseModelClass=[];
        %filter options
        filter_method='movingMean'; %a de finir en la funcion filterNoise().
        
        %plotoptions
        plottype='current';%options: 'current', 'nep'
        units='pA';%options: 'pA, fW, A, W' /raizHz.
        boolcomponents=0;
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

            obj.fCircuit=circuit;
            obj.fTES=PARAMETERS.TES;
            obj.fOperatingPoint=PARAMETERS.OP;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Filter Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function filtered_data=FilterNoise(obj,varargin)
            if nargin==1
                method=obj.filter_method;
            else
                method=varargin{1};
            end
            filtopt.model=method;
            filtopt.wmed=20;%%%
            filtopt.wmin=6;
            filtered_data=filterNoise(obj.rawVoltage,filtopt);
            obj.FilteredVoltageData=filtered_data;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Plot Noise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Plot(obj)
            scale=1;
            if strcmp(obj.units,'pA')
                scale=1e12;
            end
            loglog(obj.freqs,scale*obj.CurrentNoise,'.-')
            grid on
            if obj.boolShowFilteredData
                hold on
                %obj.FilterNoise()
                loglog(obj.freqs,scale*V2I(obj.FilteredVoltageData,obj.fCircuit),'.-k');
            end
        end
        
        %%%%%%%%%%%%%%%
        %%%Setters
        %%%%%%%%%%%%%%%
        function  SetNoiseModel(obj,model)
            parameters.OP=obj.fOperatingPoint;
            parameters.TES=obj.fTES;
            parameters.circuit=obj.fCircuit;
            obj.NoiseModelClass=NoiseThermalModelClass(parameters,model);
            if isfield(obj.fCircuit,'circuitnoise')
                circuitnoise=obj.fCircuit.circuitnoise;
            else
                circuitnoise=3e-12;
            end
            ss=obj.CurrentNoise.^2-circuitnoise.^2;
            sI=obj.NoiseModelClass.fsIHandel(obj.freqs);
            obj.NEP=sqrt(ss)./abs(sI);
        end
        %%%%%%%%%%%%%%%
        %%%Calculations
        %%%%%%%%%%%%%%%
        function Res=GetBaselineResolution(obj)
            %%%%%%%               
            Res=2.35/sqrt(trapz(f,1./obj.NEP.^2))/2/1.609e-19;
        end
        
    end %%%end methods
end