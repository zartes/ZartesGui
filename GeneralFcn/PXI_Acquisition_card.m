classdef PXI_Acquisition_card
    % Class defining a PXI Acquisition Card.
    
    properties
        ConfStructs;
        WaveFormInfo;
        Options;
        ObjHandle;
    end
    
    methods
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            %%%% Horizontal Configuration
            
            obj.ConfStructs.Horizontal.SR = 2e5;
            obj.ConfStructs.Horizontal.RL = 2e3;
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
            set(get(obj.ObjHandle,'triggering'),'trigger_source','NISCOPE_VAL_EXTERNAL');
            
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
            
            obj.Options.TimeOut = 10;
            obj.Options.channelList = '0,1';
            obj.Options.Skewness = 0.5;
            obj.Options.NAvg = 5;
        end % End of Fucntion Constructor
        
        function obj = Initialize(obj)
            % Function that initialize the values of the PXI Acquisition
            % Card
            obj = PXI_init(obj);                   
        end
                
        function obj = TF_Configuration(obj) 
            % Configuration to adquire Transfer Functions 
            
            obj.Options.TimeOut = 10;
            obj.Options.channelList = '0,1';
            
            obj.ConfStructs.Horizontal.RL = 2e6;
            pxi_ConfigureHorizontal(obj);    % ConfStructs.Horizontal
            
            obj.ConfStructs.Vertical.channelList = '0,1';
            obj = pxi_ConfigureChannels(obj);      % ConfStructs.Vertical
            
            obj.ConfStructs.Trigger.Type = 6;
            pxi_ConfigureTrigger(obj);       % ConfStructs.Trigger
        end
        
        function obj = Noise_Configuration(obj)
            % Configuration to adquire noise
            
            obj.Options.TimeOut = 5;
            obj.Options.channelList = '1';
            
            obj.ConfStructs.Horizontal.RL = 2e5;%%%2e5 para fi=1Hz, RL=2e4 para fi=10Hz.
            pxi_ConfigureHorizontal(obj);
            
            pxi_ConfigureChannels(obj);
            
            obj.ConfStructs.Trigger.Type = 6;
            obj.ConfStructs.Trigger.Source = 'NISCOPE_VAL_IMMEDIATE';
            pxi_ConfigureTrigger(obj);
        end
        
        function obj = Pulses_Configuration(obj,Level)
            % Configuration to adquire pulses
            
            pxi_ConfigureHorizontal(obj);
            pxi_ConfigureChannels(obj);            
            pxi_ConfigureTrigger(obj);
        end
        
        function [data, WfmI, TimeLapsed] = Get_Wave_Form(obj)    
            % Function for acquisition
            
            obj.AbortAcquisition;
            [data, WfmI, TimeLapsed] = pxi_GetWaveForm(obj);
        end
        
        function AbortAcquisition(obj)
            % Function to abort current acquisition
            
            invoke(obj.ObjHandle.Acquisition, 'abort');
        end
        
        function Destructor(obj)
            % Function to delete the object class
            
            disconnect(obj);
            delete(obj);
        end
        
    end
    
end

