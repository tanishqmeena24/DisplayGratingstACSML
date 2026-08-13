% This program continuously scans the NI card for certain digital codes,
% and                                                      
% controls the tES device based on the instructions through the NI card

% MATLAB Data Acquisition Toolbox and NI-DAQmx must both be installed

function readNIAndControltES
% 1. Configure the NI card
devices = daqlist("ni"); % Find NI devices

    if isempty(devices)
        error('No NI devices found. Please check the connection.');
    end

% Select the first available device for data acquisition
dq = daq("ni");

% 2. Configure the Digital Input Channels
deviceName = devices.DeviceID;      % The alias given to your device in NI MAX
portName   = "port0";               % NI digital port
lineName   = "line0:3";             % Lines 0 to 3 configured as a single bus

% Combine to create the valid resource ID format: "port0/line0:3"
channelID  = portName + "/" + lineName;

% Add the digital lines to the session as Input channels
addinput(dq, deviceName, channelID, "Digital");

% Display object configuration info in the Command Window
disp("DAQ Session Initialized Successfully:");
disp(dq);

% Establish connection with the tES device
outlet = Start_up(); % The LSL Initiation script to connect with the device

disp('---------------------------------------------------------')
disp('Connect GUI to the stimulation device.')
disp('---------------------------------------------------------')

pIntensity = struct("Action",7,"Intensity",0.1); % From -3 mA to +3 mA
JSONIntensity = jsonencode(pIntensity);
ptACS = struct('Action',7,'WaveformType','tACS'); % -tACS- or tDCS or tRNS
JSONtACS = jsonencode(ptACS);
pDuration = struct("Action",7,"Duration",3); % From 10 sec to 7200 sec
JSONDuration = jsonencode(pDuration);
pDelay = struct("Action",7,"Delay",0); % From 0 msec to 600 msec
JSONDelay = jsonencode(pDelay);
pRampUp = struct("Action",7,"RampUp",0); % From 0 sec to 127 sec
JSONRampUp = jsonencode(pRampUp);
pChannel2 = struct("Action",0,"ChannelNumber",2); % Channel to be stimulated
JSONaddChannel2 = jsonencode(pChannel2);
pFrequency2 = struct('Action',7,'ChannelNumber',2,'Frequency',20); %250); % From 0.1 Hz to 5,000 Hz
JSONFrequency2 = jsonencode(pFrequency2);
pLoad = struct("Action",3);
JSONLoad = jsonencode(pLoad);

outlet.push_sample({JSONIntensity}); pause(0.1)
outlet.push_sample({JSONtACS}); pause(0.1)
outlet.push_sample({JSONDuration}); pause(0.1)
outlet.push_sample({JSONDelay}); pause(0.1)
outlet.push_sample({JSONRampUp}); pause(0.1)
outlet.push_sample({JSONaddChannel2}); pause(0.1)
outlet.push_sample({JSONFrequency2}); pause(0.1)
outlet.push_sample({JSONLoad}); pause(0.5)
disp('Loaded once')

oldDigitalCode = 0;

    while(1) % Do this continuously
        digitalCode = bin2dec(fliplr(num2str(table2array(read(dq))))); % Read the digital code from the NI card
        if digitalCode ~= oldDigitalCode
            controltES(digitalCode); % Control the tES device based on the read code
            oldDigitalCode = digitalCode;
        end
    end

    function controltES(digitalCode)
        disp(digitalCode);

    % Load at the end of the trial
        if digitalCode==2 % trial end
            % load tACS
            pLoad = struct("Action",3);
            JSONLoad = jsonencode(pLoad);
            outlet.push_sample({JSONLoad});
            disp('Loaded for the next trial')

        elseif digitalCode==7 % stimulation start
            % run stimulation
            pStartStimulation = struct("Action",4);
            StartJSON = jsonencode(pStartStimulation);
            outlet.push_sample({StartJSON});
            disp('Started')

        elseif digitalCode==3 % stimulation stop
            % stop stimulation
            pStopStimulation = struct("Action",5);
            StopJSON = jsonencode(pStopStimulation);
            outlet.push_sample({StopJSON});
            disp('Aborting...')
        end
    end
end
