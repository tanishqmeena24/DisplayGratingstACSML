
%% TACS Parameters
%Settings: Intensity
pIntensity = struct("Action",7,"Intensity",0.03);
JSONIntensity = jsonencode(pIntensity);

%Settings: Waveform Change tACS
ptACS = struct('Action',7,'WaveformType','tACS');
JSONtACS = jsonencode(ptACS);

%Settings: Duration
pDuration = struct("Action",7,"Duration",3);
JSONDuration = jsonencode(pDuration);

%Settings: Delay
pDelay = struct("Action",7,"Delay",0);
JSONDelay = jsonencode(pDelay);

%Settings: RampUp
pRampUp = struct("Action",7,"RampUp",0);
JSONRampUp = jsonencode(pRampUp);

%Add Channel
pChannel2 = struct("Action",0,"ChannelNumber",2);
JSONaddChannel2 = jsonencode(pChannel2);

%Settings: Frequency
pFrequency2 = struct('Action',7,'ChannelNumber',2,'Frequency',10);   %250);
JSONFrequency2 = jsonencode(pFrequency2);

%Add Channel
% pChannel14 = struct("Action",0,"ChannelNumber",14);
% JSONaddChannel14 = jsonencode(pChannel14);
% 
% %Settings: Frequency
% pFrequency14 = struct('Action',7,'ChannelNumber',14,'Frequency',150);
% JSONFrequency14 = jsonencode(pFrequency14);

%Load Device
pLoad = struct("Action",3);
JSONLoad = jsonencode(pLoad);

%Starting Stimulation 
pstartStimulation = struct("Action",4);
JSONstartStimulation = jsonencode(pstartStimulation);

%Stop Stimulation 
pstopStimulation = struct("Action",5);
JSONstopStimulation = jsonencode(pstopStimulation);

%% -------------------------------------------------------------------- %%

%% Sending Commands to MXN

% outlet.push_sample({JSONIntensity});
% pause(1)
% outlet.push_sample({JSONtACS});
% pause(1)
% outlet.push_sample({JSONDuration});
% pause(1)
% outlet.push_sample({JSONDelay});
% pause(1)
% outlet.push_sample({JSONRampUp});
% pause(1)
% outlet.push_sample({JSONaddChannel});
% pause(1)
% outlet.push_sample({JSONFrequency});
% pause(1)
% outlet.push_sample({JSONLoad});
% pause(1)
% outlet.push_sample({JSONstartStimulation});
% pause(1);
% outlet.push_sample({JSONstopStimulation});
% pause(1)
