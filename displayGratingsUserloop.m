function [C,timingfile,userdefined_trialholder] = displayGratingsUserloop(~,TrialRecord)
% Adapted from Pai's grating completion protocol
% default return value

C = [];
% timingfile = 'displayGratingsTiming.m';
timingfile = 'displayGratingsTimingAdapter.m';      % Timing file that uses the Cerestim Adapter
userdefined_trialholder = '';

% Number of total blocks, in case the task is to be quit after an exact
% number of blocks
num_blocks = 100;     % Should always be an even number

if mod(num_blocks,2) == 1
    error("num_blocks should be an even number")
end

% define variables to keep track of the stimuli shown/remaining
persistent stimList                 % List of stimuli left to display in a block
persistent stimPrev                 % List of stimuli of the current block displayed in the prev trial
persistent stimBorrow               % List of stimuli of the next block displayed in the prev trial

% Create a table of all stimulus combinations and return timing file if it's the very first call
persistent stimTable
persistent stimLength
persistent blockSum

persistent lsl_init             % Initializes LSL Library for tACS
persistent tacs_loaded          % To record the loading of tACS parameters

deviceConfig                    % Contains the flag for the stimulation device
TrialRecord.User.DeviceFlag = DeviceFlag;

if isempty(stimTable)

    % Prerequisite variables (HARDCODED):
    % Grating parameters
    params.RF = "IN"; % Receptive Field (RF) conditions, IN/OUT
    params.azi = 0; % Azimuths (deg), V1_dona = -1.75, V4_dona = -1.35
    params.ele = 0; % Elevations (deg), V1_dona = -2.5, V4_dona = -0.6
    params.radii = 1000; % Aperture radii (deg)
    params.sf = 0.5*(2.^(0:3)); % Spatial Frequencies (SFs) (cpd)
    params.ori = (0:45:135); % Orientations (deg)
    params.con = 100; %[25, 50, 100]; % Contrasts (%)

    % params.amp = [0, 3]; % For tDCS
    params.amp = [0, 1.5]; % For tACS Dona
    % params.amp = [0, 2.5]; % For tACS Jojo

    params.frequency = 20; % tACS Frequency


    if DeviceFlag == 1                 % For Microstim
        
    % Microstimulation parameters
        params.amp = 16;   % Current amplitude (μA)
        params.pulses = 7;  % Number of biphasic pulses
        params.frequency = [0,20,30,40,50,60,70,80];  % Frequency of biphasic pulses
        params.duration = 300; % ms; When duration > 0, pulses is determined by frequency
    
    elseif DeviceFlag == 2             % For tACS
        
        % if isempty(lsl_init)
        %     Start_up();                     % The LSL initialization script
        %     TrialRecord.User.outlet = outlet;
        %     lsl_init = true;
        % 
        %     disp('------------------------------------------')
        %     disp('Connect GUI to stimulation device')
        %     disp('------------------------------------------')
        % 
        %     pause(2);
        % end

        % TrialRecord.User.currentStimulus = 1; % Commenting for testing


        if isempty(tacs_loaded)

        % The LSL communication with Soterix Laptop will go here

        % Load tACS parameters
        % pIntensity = struct("Action",7,"Intensity",1.5); % From -3 mA to +3 mA
        % JSONIntensity = jsonencode(pIntensity);
        % ptACS = struct('Action',7,'WaveformType','tACS'); % -tACS- or tDCS or tRNS
        % JSONtACS = jsonencode(ptACS);
        % pDuration = struct("Action",7,"Duration",3); % From 10 sec to 7200 sec
        % JSONDuration = jsonencode(pDuration);
        % pDelay = struct("Action",7,"Delay",0); % From 0 msec to 600 msec
        % JSONDelay = jsonencode(pDelay);
        % pRampUp = struct("Action",7,"RampUp",0); % From 0 sec to 127 sec
        % JSONRampUp = jsonencode(pRampUp);
        % pChannel2 = struct("Action",0,"ChannelNumber",2); % Channel to be stimulated
        % JSONaddChannel2 = jsonencode(pChannel2);
        % pWaveform = struct("ChannelNumber", 2, "Action", 1, "PathToFile", "C:\Users\sraylab\Desktop\SoterixMedical\HD-SC Constant Current Version 3.0.4\waveforms_files\full_sine.txt");
        % % JSONWaveform = jsonencode(pWaveform)
        % pFrequency2 = struct('Action',7,'ChannelNumber',2,'Frequency',20); %250); % From 0.1 Hz to 5,000 Hz
        % JSONFrequency2 = jsonencode(pFrequency2);
        % % pLoad = struct("Action",3);
        % % JSONLoad = jsonencode(pLoad);
        % % pstartStimulation = struct("Action",4);
        % % JSONstartStimulation = jsonencode(pstartStimulation);
        % % pstopStimulation = struct("Action",5);
        % % JSONstopStimulation = jsonencode(pstopStimulation);

        
        % % Send configuration commands to the tACS device once
        % outlet.push_sample({JSONIntensity}); pause(0.1)
        % outlet.push_sample({JSONtACS}); pause(0.1)
        % outlet.push_sample({JSONDuration}); pause(0.1)
        % outlet.push_sample({JSONDelay}); pause(0.1)
        % outlet.push_sample({JSONRampUp}); pause(0.1)
        % outlet.push_sample({JSONaddChannel2}); pause(0.1)
        % % outlet.push_sample({JSONaddChannel14}); pause(0.5)
        % outlet.push_sample({JSONFrequency2}); pause(0.1)
        % % --- Frequency of each added channel needs to be specified here --- %
        % % outlet.push_sample({JSONFrequency14}); pause(0.5)
        % % % outlet.push_sample({JSONLoad}); pause(0.5)


            tacs_loaded = true;

        end
        TrialRecord.User.Stimulator = tacs_loaded;
    end

    if DeviceFlag == 1             % For Microstim
        % Define the channel to be stimulated
        % Ch 12 -> elec1-27
        % Ch 95 -> elec1-1
        TrialRecord.User.MicrostimChannel = 95;

        % Create stimulator object
        stimulator = cerestim96();

        % Scan for devices
        DeviceList = stimulator.scanForDevices();    

        if ~isempty(DeviceList)
            % Select a device to connect to block
            stimulator.selectDevice(0);

            % Connect to the stimulator
            stimulator.connect; 

            TrialRecord.User.Stimulator = stimulator;
        else
            TrialRecord.User.Stimulator = [];
            disp("No Stimulator Devices conected");

        end
        return

    end
    
    % Creating the stimulus table:
    stimTable = create_stimtable(params=params);
    stimLength = size(stimTable, 1);
    TrialRecord.User.StimTable = stimTable;

    blockSum = 0;
    stimList = [];
    stimBorrow = [];
    stimPrev = [];
    return

end

stim_per_trial = TrialRecord.Editable.stim_per_trial;
block = TrialRecord.CurrentBlock;
condition = TrialRecord.CurrentCondition;

if isempty(TrialRecord.TrialErrors)                                         % If it's the first trial
    condition = 1;                                                          % set the condition # to 1
elseif ~isempty(TrialRecord.TrialErrors) && 0 == TrialRecord.TrialErrors(end) % If the last trial is a success
    stimList = setdiff(stimList, stimPrev);                                 % remove previous trial stimuli from the list of stimuli
    condition = mod(condition + stim_per_trial - 1, stimLength) + 1;        % increment the condition # by stim_per_trial
end

% Initialize the conditions for a new block
if isempty(stimList)                                            % If there are no stimuli left in the block
    stimList = setdiff(1:stimLength, stimBorrow);
    block = block + blockSum + 1;
    stimBorrow = [];
    blockSum = 0;
end

if length(stimList) >= stim_per_trial                                         % If more than 2 stimuli left in the current block
    stimCurrent = datasample(stimList, stim_per_trial, 'Replace',false);    % randomly sample 3 stimuli from the list
    stimPrev = stimCurrent;
elseif length(stimList) + stimLength > stim_per_trial
    stimPrev = stimList;
    stimBorrow = datasample(1:stimLength, stim_per_trial-length(stimList), 'Replace', false);
    stimCurrent = [stimList stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));
else
    stimPrev = stimList;
    blockSum = floor((stim_per_trial - length(stimList)) / stimLength);
    stimBorrow = datasample(1:stimLength, stim_per_trial - length(stimList) - blockSum * stimLength, 'Replace', false);
    stimCurrent = [stimList repmat(1:stimLength,1,blockSum) stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));
end

Info = stimTable(stimCurrent, :);
for j = string(Info.Properties.VariableNames)
    for i = 1:stim_per_trial
        Info_struct.(strcat(j, string(i))) = Info.(j)(i);
    end
end

TrialRecord.setCurrentConditionInfo(Info_struct);

% Set the stimuli
stim = cell(1,stim_per_trial);
for i=1:stim_per_trial
    stim{i} = 'gen(make_grating.m)';
end

if DeviceFlag == 1                 % For Microstim
    C = cell(1,stim_per_trial);
    for i=1:stim_per_trial
        C{i} = stim{i};
    end
elseif DeviceFlag == 2                 % For tACS
    C = stim;
end

TrialRecord.User.Stimuli = stimCurrent;             % save the stimuli for the next trial in user variable
TrialRecord.User.stim_idx = 1;

if block == num_blocks + 1
        TrialRecord.NextBlock = -1;     % Exit if the next block number reaches the maximum number of blocks
else
    TrialRecord.NextBlock = block;
end
