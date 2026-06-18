
hotkey('x','escape_screen(); assignin(''caller'',''continue_'',false);');

set_bgcolor([0.5 0.5 0.5]);

bhv_variable('Stimuli',TrialRecord.User.Stimuli);

if exist('eye_','var')
    tracker = eye_;
else
    error('Eye tracker required');
end


stim_per_trial = 2; %3;
stim = 1:stim_per_trial;

wait_for_fix = 2000;
hold_fix = 1250;
stimulus_duration = 1250; % 500; %3000; %1250;
isi_duration = 3000;  % 1250;
pulse_duration = 50; %300;

fix_size = 0.2;
fix_color = [1 1 1];
fix_window = [3 3];
hold_window = fix_window;

tacs_enable = true;

editable('tacs_enable');


fixation_point = CircleGraphic(null_);
fixation_point.EdgeColor = fix_color;
fixation_point.FaceColor = fix_color;
fixation_point.Size = fix_size;
fixation_point.Position = [0 0];


fix1 = SingleTarget(tracker);
fix1.Target = fixation_point;
fix1.Threshold = fix_window;

wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = 1;
wth1.AllowEarlyFix = true;

sceneFix = create_scene(wth1);


fix2 = SingleTarget(tracker);
fix2.Target = fixation_point;
fix2.Threshold = fix_window;

wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = hold_fix;

sceneHold = create_scene(wth2);

sceneStim = cell(1, stim_per_trial);

fix3 = SingleTarget(tracker);
fix3.Target = fixation_point;
fix3.Threshold = fix_window;

wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = stimulus_duration;

% % 
stimAdapter = tACSAdapter(wth3,...   %(null_,...
    TrialRecord.User.JSONstartStimulation,...
    TrialRecord.User.JSONstopStimulation,...
    TrialRecord.User.JSONLoad,...
    TrialRecord.User.outlet,...
    TrialRecord.User.currentStimulus);

% stimAdapter.StartJSON = TrialRecord.User.JSONstartStimulation;
% stimAdapter.StopJSON  = TrialRecord.User.JSONstopStimulation;
% 
% stimAdapter.outlet = TrialRecord.User.outlet;

% 
% con3 = Concurrent(wth3);
% con3.add(stimAdapter);
    
for i = 1:stim_per_trial
    % fix3 = SingleTarget(tracker);
    % fix3.Target = fixation_point;
    % fix3.Threshold = fix_window;
    % 
    % wth3 = WaitThenHold(fix3);
    % wth3.WaitTime = 0;
    % wth3.HoldTime = stimulus_duration;
    % 
    % % % 
    % stimAdapter = tACSStimAdapter(null_,...
    %     TrialRecord.User.JSONstartStimulation,...
    %     TrialRecord.User.JSONstopStimulation,...
    %     TrialRecord.User.outlet);
    % 
    % % stimAdapter.StartJSON = TrialRecord.User.JSONstartStimulation;
    % % stimAdapter.StopJSON  = TrialRecord.User.JSONstopStimulation;
    % % 
    % % stimAdapter.outlet = TrialRecord.User.outlet;
    % 
    % con3 = Concurrent(wth3);
    % con3.add(stimAdapter);
    % 
    sceneStim{i} = create_scene(stimAdapter, stim(i));
end

fix4 = SingleTarget(tracker);
fix4.Target = fixation_point;
fix4.Threshold = hold_window;

wth4 = WaitThenHold(fix4);
wth4.WaitTime = 0;
wth4.HoldTime = isi_duration;

sceneISI = create_scene(wth4);

error_type = 0;
flag = 0;

while true

    % TrialRecord.User.out.push_sample({TrialRecord.User.JSONLoad});
    % pause(2.5);
    run_scene(sceneFix);
    if ~wth1.Success; error_type = 4; break; end

    run_scene(sceneHold,6); %5 %10         %% Marker for Fixation Acquired
    if ~wth2.Success; error_type = 3; break; end

    for i = 1:stim_per_trial
        % % 
        TrialRecord.User.out.push_sample({TrialRecord.User.JSONLoad}); 
        pause(2.5);
        % eventmarker(40);                  % Added for stim ON
        run_scene(sceneStim{i},7);          %3 %31 = grating ON

        % eventmarker(41);          % Added for marker for stim OFF
        % eventmarker(32);          % Added for marker for grating OFF
        if ~wth3.Success
            error_type = 3;
            flag = 1;
            break;
        end

        if i < stim_per_trial
            % TrialRecord.User.out.push_sample({TrialRecord.User.JSONLoad}); 
            run_scene(sceneISI, 3);    % Grating OFF
            % eventmarker(3); % Also serves as marker for grating OFF

            if ~wth4.Success
                error_type = 3;
                flag = 1;
                break;
            end

        end

    end

    if flag==1; break; end

    idle(0);

    goodmonkey(pulse_duration,'juiceline',1,'numreward',1,'eventmarker',4);  %4, 2, 50

    break

end


if error_type ~=0
    idle(700);
end

trialerror(error_type);
disp('trial done');
set_iti(500) %1000);
