%add library path
addpath(genpath('C:\Users\TANISHQ\Desktop\SoterixMedical\HD-SC Constant Current Version 3.0.4'))

%Initiating LSL Library
lib = lsl_loadlib();
info = lsl_streaminfo(lib,'HD-SC_Markers','Markers',1,0,'cf_string');
outlet = lsl_outlet(info);

disp("Start_up.m is running") %Just a check
