function [C,timingfile,userdefined_trialholder] = displayGratingsUserloop(~,TrialRecord)
% Adapted from Pai's grating completion protocol
% default return value
C = [];
% timingfile = 'displayGratingsTiming.m';
timingfile = 'displayGratingsTimingtACS.m';      % Timing file that uses the tACSAdapter Adapter
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

% Createa table of all stimulus combinations and return timing file if it the very first call
persistent stimTable
persistent stimLength
persistent blockSum

persistent lsl_init
persistent tacs_loaded

if isempty(stimTable)

    % -----------------------------
    % Initialize LSL outlet
    % -----------------------------
    if isempty(lsl_init)
        Start_up();          % your LSL initialization script
        TrialRecord.User.outlet = outlet;
        lsl_init = true;

        disp('------------------------------------------')
        disp('1. Open stimulation GUI')
        disp('2. Login to GUI')
        disp('3. Connect GUI to stimulation device')
        disp('------------------------------------------')

        pause(4);
    end
    % % 
    TrialRecord.User.currentStimulus = 1;

    % -----------------------------
    % Load tACS parameters
    % -----------------------------
    if isempty(tacs_loaded)

        tacs_params    % <-- your JSON parameter script

        TrialRecord.User.JSONIntensity = JSONIntensity;
        TrialRecord.User.JSONtACS = JSONtACS;
        TrialRecord.User.JSONDuration = JSONDuration;
        TrialRecord.User.JSONDelay = JSONDelay;
        TrialRecord.User.JSONRampUp = JSONRampUp;
        TrialRecord.User.JSONaddChannel2 = JSONaddChannel2;
        % TrialRecord.User.JSONaddChannel14 = JSONaddChannel14;
        TrialRecord.User.JSONLoad = JSONLoad;
        TrialRecord.User.JSONstartStimulation = JSONstartStimulation;
        TrialRecord.User.JSONstopStimulation = JSONstopStimulation;
        % % 
        TrialRecord.User.out = outlet;

        % Send configuration commands once
        outlet.push_sample({JSONIntensity}); pause(0.5)
        outlet.push_sample({JSONtACS}); pause(0.5)
        outlet.push_sample({JSONDuration}); pause(0.5)
        outlet.push_sample({JSONDelay}); pause(0.5)
        outlet.push_sample({JSONRampUp}); pause(0.5)
        outlet.push_sample({JSONaddChannel2}); pause(0.5)
        % outlet.push_sample({JSONaddChannel14}); pause(0.5)
        outlet.push_sample({JSONFrequency2}); pause(0.5)
        % outlet.push_sample({JSONFrequency14}); pause(0.5)
        % % outlet.push_sample({JSONLoad}); pause(0.5)

        tacs_loaded = true;

    end    
    
    % Prerequisite variables (HARDCODED):
    % Grating parameters
    params.RF = "IN"; % Receptive Field (RF) conditions, IN/OUT
    params.azi = 0; % Azimuths (deg), V1_dona = -1.75, V4_dona = -1.35
    params.ele = 0; % Elevations (deg), V1_dona = -2.5, V4_dona = -0.6
    params.radii = 1000; % Aperture radii (deg)
    params.sf = 0.5*(2.^(0:3)); % Spatial Frequencies (SFs) (cpd)
    params.ori = (0:45:135); % Orientations (deg)
    params.con = [25,50,100]; % Contrasts (%)
    
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
   

stim_per_trial = 3;
TrialRecord.User.stim_per_trial = stim_per_trial;

% % 
TrialRecord.User.currentStimulus = 1;

% % TrialRecord.User.out.push_sample({TrialRecord.User.JSONLoad}); 
% pause(1);

if isfield(TrialRecord,'CurrentBlock')
    block = TrialRecord.CurrentBlock;
else
    block = 1;
end

if isfield(TrialRecord,'CurrentCondition')
    condition = TrialRecord.CurrentCondition;
else
    condition = 1;
end


if isempty(TrialRecord.TrialErrors)

    condition = 1;

elseif ~isempty(TrialRecord.TrialErrors) && 0==TrialRecord.TrialErrors(end)

    stimList = setdiff(stimList, stimPrev);
    condition = mod(condition+stim_per_trial-1, stimLength)+1;

end


if isempty(stimList)

    stimList = setdiff(1:stimLength, stimBorrow);
    block = block + blockSum + 1;

    stimBorrow = [];
    blockSum = 0;

end


if length(stimList)>=stim_per_trial

    stimCurrent = datasample(stimList, stim_per_trial, 'Replace',false);
    stimPrev = stimCurrent;

elseif length(stimList)+stimLength>stim_per_trial

    stimPrev = stimList;
    stimBorrow = datasample(1:stimLength, stim_per_trial-length(stimList),'Replace',false);

    stimCurrent = [stimList stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));

else

    stimPrev = stimList;

    blockSum = floor((stim_per_trial-length(stimList))/stimLength);

    stimBorrow = datasample(1:stimLength, stim_per_trial-length(stimList)-blockSum*stimLength,'Replace',false);

    stimCurrent = [stimList repmat(1:stimLength,1,blockSum) stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));

end


Info = stimTable(stimCurrent,:);

for j = string(Info.Properties.VariableNames)

    for i = 1:stim_per_trial
        Info_struct.(strcat(j,string(i))) = Info.(j)(i);
    end

end


TrialRecord.setCurrentConditionInfo(Info_struct);


stim = cell(1,stim_per_trial);

for i=1:stim_per_trial
    stim{i} = 'gen(make_grating.m)';
end

C = stim;

TrialRecord.User.Stimuli = stimCurrent;
TrialRecord.User.stim_idx = 1;


TrialRecord.NextBlock = block;
TrialRecord.NextCondition = condition;