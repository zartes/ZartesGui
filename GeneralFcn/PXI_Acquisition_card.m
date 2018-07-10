classdef PXI_Acquisition_card
        
    properties
        ConfStructs;
        WaveFormInfo;
        Options;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            %%%% Horizontal Configuration
            obj.ConfStructs.Horizontal.SR = 2e5;
            obj.ConfStructs.Horizontal.RL = 2e4;
            obj.ConfStructs.Horizontal.RefPos = 20;
            
            %%%% Vertical Configuration
            obj.ConfStructs.Vertical.ChannelList = '0,1';
            obj.ConfStructs.Vertical.Range = 0.0025;
            obj.ConfStructs.Vertical.Coupling = 'dc';
            obj.ConfStructs.Vertical.ProbeAttenuation = 1;
            obj.ConfStructs.Vertical.offset = 0;
            obj.ConfStructs.Vertical.Enabled = 1;
            
            %%% Trigger Configuration
            obj.ConfStructs.Trigger.Source = '1';
            obj.ConfStructs.Trigger.Type = 1;
            obj.ConfStructs.Trigger.Slope = 0;%%%0:Neg, 1:Pos
            obj.ConfStructs.Trigger.Level = -0.05; %%%%Habrá que resetear el lazo del Squid pq el ch1 se acopla en DC.
            obj.ConfStructs.Trigger.Coupling = 1;%%%DC=1; AC=0;?. '0' da error.
            obj.ConfStructs.Trigger.Holdoff = 0;
            obj.ConfStructs.Trigger.Delay = 0;
            
            if length(obj.ConfStructs.Vertical.ChannelList) == 1
                nchannels = 1;
            else
                nchannels = 2;
            end
            for i = 1:nchannels
                obj.WaveFormInfo(i).absoluteInitialX = 0;
                obj.WaveFormInfo(i).relativeInitialX = 0;
                obj.WaveFormInfo(i).xIncrement = 0;
                obj.WaveFormInfo(i).actualSamples = 0;
                obj.WaveFormInfo(i).offset = 0;
                obj.WaveFormInfo(i).gain = 0;
                obj.WaveFormInfo(i).reserved1 = 0;
                obj.WaveFormInfo(i).reserved2 = 0;
            end            
        end % End of Fucntion Constructor
        
        function obj = Initialize(obj)            
            addpath('G:\Mi unidad\ICMA\zartes_ACQ-master\PXI\'); 
            obj = PXI_init_updated(obj);                   
        end
                
        function obj = TF_Configuration(obj) % Measure Transfer Functions 
            obj.Options.TimeOut = 10;
            obj.Options.channelList = '0,1';
            
            obj.ConfStructs.Horizontal.RL = 2e6;
            obj = pxi_ConfigureHorizontal_updated(obj);    % ConfStructs.Horizontal
            
            obj.ConfStructs.Vertical.channelList = '0,1';
            obj = pxi_ConfigureChannels_updated(obj);      % ConfStructs.Vertical
            
            obj.ConfStructs.Trigger.Type = 6;
            obj = pxi_ConfigureTrigger_updated(obj);       % ConfStructs.Trigger
        end
        
        function obj = Noise_Configuration(obj)
            obj.Options.TimeOut = 5;
            obj.Options.channelList = '1';
            
            obj.ConfStructs.Horizontal.RL = 2e5;%%%2e5 para fi=1Hz, RL=2e4 para fi=10Hz.
            pxi_ConfigureHorizontal_updated(pxi)
            
            pxi_ConfigureChannels_updated(pxi)
            
            obj.ConfStructs.Trigger.Type = 6;
            obj.ConfStructs.Trigger.Source = 'NISCOPE_VAL_IMMEDIATE';
            pxi_ConfigureTrigger_updated(pxi)
        end
        
        function obj = Pulses_Configuration(obj,Level)
            obj.ConfStructs.Horizontal.SR = 5e6;
            obj.ConfStructs.Horizontal.RL = 25e3; %%%2e4 cubre los 2mseg a 10MS/S pero si pa RefPos=20% no se coge todo el pulso.
            pxi_ConfigureHorizontal_updated(obj)
            
            obj.ConfStructs.Vertical.Range = 1;
            pxi_ConfigureChannels_updated(obj)            
            
            obj.ConfStructs.Trigger.Type = 1; %%%%El trigger Edge no funciona.            
            if nargin > 1
                obj.ConfStructs.Trigger.Level = Level;                
            end            
            pxi_ConfigureTrigger_updated(obj)            
            if obj.ConfStructs.Trigger.Type == 1003.0
                HighLevel = obj.ConfStructs.Trigger.Level;
                LowLevel = HighLevel-0.1;
                set(obj.ObjHandle.Triggeringtriggerwindow,'High_Window_Level',HighLevel);
                set(obj.ObjHandle.Triggeringtriggerwindow,'Low_Window_Level',LowLevel);
            end
        end
        
        function [data, WfmI] = Get_Wave_Form(obj)
            [data, WfmI] = pxi_GetWaveForm_updated(obj);
        end
        
        function AbortAcquisition(obj)
            invoke(obj.ObjHandle.Acquisition, 'abort');
        end
        
        function Destructor(obj)
            disconnect(obj);
            delete(obj);
        end
        
    end
    
end

