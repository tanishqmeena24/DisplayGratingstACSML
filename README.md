## Gratings Protocol with Transcranial Alternating Current Stimulation, or tACS

### Dependencies

##### NIMH MonkeyLogic
The latest version can be obtained from https://monkeylogic.nimh.nih.gov/download.html. 
This code was written using verion 2.2.37 (Recommended).
Please refer to the documentation (https://monkeylogic.nimh.nih.gov/index.html) for information on usage.

##### Additional scripts
Three scripts are needed other than the displayGratingsUserloop.m and displayGratingsTimingtACS.m.
These are:
1. Start_up.m (for LSL initialization to connect to the device),
2. tACSParams (contains the parameters for tACS, which are sent to the device via LSL), and
3. tACSAdapter


### Please note:
The task can run without a Soterix Medical HD-tES MxN-33 device connected.
