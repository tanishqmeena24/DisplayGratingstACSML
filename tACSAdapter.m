classdef tACSAdapter < mladapter

    properties
        JSONLoad
        StartJSON
        StopJSON
        outlet
        currentStimulus
        Intensity
        Frequency
    end

    properties (Access = protected)
        stim_started = false
    end

    methods

        function obj = tACSAdapter(varargin)
            % obj = obj@mladapter(varargin{:});
            % % 
            obj@mladapter(varargin{1});
            obj.StartJSON = varargin{2};
            obj.StopJSON = varargin{3};
            obj.JSONLoad = varargin{4};
            obj.outlet = varargin{5};
            obj.currentStimulus = varargin{6};

            obj.Intensity = varargin{7};
            disp("Creating Adapter...")
            obj.Frequency = varargin{8};
            obj.setWaveform();

          
        end

        function init(obj, p)  %init(obj,~)
            % % 
            init@mladapter(obj, p);
            obj.stim_started = false;
        end

        function continue_ = analyze(obj,p)
            continue_ = analyze@mladapter(obj, p);

            % % 
            if obj.currentStimulus == 1
                % obj.currentStimulus = 2;
                if continue_ && ~obj.stim_started
                    % % obj.outlet.push_sample({obj.JSONLoad});    % takes time
                    % to load, causes problems
                    % % pause(1)
                    obj.outlet.push_sample({obj.StartJSON});
                    p.DAQ.eventmarker(1);
                    obj.stim_started = true;
                    disp('START')
                end
    
                % continue_ = obj.Adapter.analyze(p);
    
                if ~continue_ && obj.stim_started
                    obj.outlet.push_sample({obj.StopJSON});
                    p.DAQ.eventmarker(2);
                    obj.stim_started = false;
                    disp('STOP')
                end
                obj.Success = obj.Adapter.Success;
            end
        end

        function draw(obj,p)
            draw@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end

        function fini(obj,p)

            % safety stop
            if obj.stim_started
                obj.outlet.push_sample({obj.StopJSON});
                obj.stim_started = false;
                disp('STOP')
            end

            fini@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end

        function setWaveform(obj)
            % disp(obj.Intensity)
            pIntensity = struct("Action",7,"Intensity",obj.Intensity); % From -3 mA to +3 mA
            JSONIntensity = jsonencode(pIntensity);
            ptACS = struct('Action',7,'WaveformType','tACS'); % -tACS- or tDCS or tRNS or Amplitude Modulation
            JSONtACS = jsonencode(ptACS);
            pDuration = struct("Action",7,"Duration",3); % From 10 sec to 7200 sec
            JSONDuration = jsonencode(pDuration);
            pDelay = struct("Action",7,"Delay",0); % From 0 msec to 600 msec
            JSONDelay = jsonencode(pDelay);
            pRampUp = struct("Action",7,"RampUp",0); % From 0 sec to 127 sec
            JSONRampUp = jsonencode(pRampUp);
            pChannel2 = struct("Action",0,"ChannelNumber",2); % Channel to be stimulated
            JSONaddChannel2 = jsonencode(pChannel2);
            pFrequency2 = struct('Action',7,'ChannelNumber',2,'Frequency',10); %250); % From 0.1 Hz to 5,000 Hz
            JSONFrequency2 = jsonencode(pFrequency2);
            pLoad = struct("Action",3);
            obj.JSONLoad = jsonencode(pLoad);
            pstartStimulation = struct("Action",4);
            obj.StartJSON = jsonencode(pstartStimulation);
            pstopStimulation = struct("Action",5);
            obj.StopJSON = jsonencode(pstopStimulation);

        % Send configuration commands to the tACS device once
            obj.outlet.push_sample({JSONIntensity}); pause(0.1)
            obj.outlet.push_sample({JSONtACS}); pause(0.1)
            obj.outlet.push_sample({JSONDuration}); pause(0.1)
            obj.outlet.push_sample({JSONDelay}); pause(0.1)
            obj.outlet.push_sample({JSONRampUp}); pause(0.1)
            obj.outlet.push_sample({JSONaddChannel2}); pause(0.1)
            % % outlet.push_sample({JSONaddChannel14}); pause(0.5)
            obj.outlet.push_sample({JSONFrequency2}); pause(0.1)
            % --- Frequency of each added channel needs to be specified here --- %
            % outlet.push_sample({JSONFrequency14}); pause(0.5)
            obj.outlet.push_sample({obj.JSONLoad}); pause(2)
            disp("Waveform Loaded")
        end
    end
end
