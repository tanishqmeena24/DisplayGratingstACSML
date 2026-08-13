classdef tACSAdapter < mladapter

    properties
        JSONLoad
        StartJSON
        StopJSON
        outlet
        currentStimulus
        % Intensity
        % Frequency
    end

    properties (Access = protected)
        stim_started = false
    end

    methods

        function obj = tACSAdapter(varargin)
            % obj = obj@mladapter(varargin{:});
            obj@mladapter(varargin{1});
            obj.StartJSON = varargin{2};
            obj.StopJSON = varargin{3};
            obj.JSONLoad = varargin{4};
            obj.outlet = varargin{5};
            obj.currentStimulus = varargin{6};

            % obj.Intensity = varargin{7};
            % disp("Creating Adapter...")
            % obj.Frequency = varargin{8};
            % obj.setWaveform();

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
                    % % obj.outlet.push_sample({obj.JSONLoad});

                    % % pause(1)
                    % obj.outlet.push_sample({obj.StartJSON});
                    p.DAQ.eventmarker(7);
                    obj.stim_started = true;
                    % disp('START')
                end
    
                % continue_ = obj.Adapter.analyze(p);
                if ~continue_ && obj.stim_started
                    % obj.outlet.push_sample({obj.StopJSON});
                    % p.DAQ.eventmarker(2);
                    % obj.stim_started = false;
                    % disp('STOP')
                end
                obj.Success = obj.Adapter.Success;
            end
        end

        function draw(obj,p)
            draw@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end

        function fini(obj,p)

            % safety stop
            % if obj.stim_started
            %     obj.outlet.push_sample({obj.StopJSON});
            %     obj.stim_started = false;
            %     disp('STOP')
            % end

            fini@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end
    end
end
