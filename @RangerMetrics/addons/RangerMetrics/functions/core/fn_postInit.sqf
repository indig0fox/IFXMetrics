// if (!isServer) exitWith {};

if (is3DEN || !isMultiplayer) exitWith {};
if (!isServer && hasInterface) exitWith {};

RangerMetrics_cbaPresent = isClass(configFile >> "CfgPatches" >> "cba_main");
RangerMetrics_aceMedicalPresent = isClass(configFile >> "CfgPatches" >> "ace_medical_status");
RangerMetrics_logPrefix = "RangerMetrics";
RangerMetrics_debug = false;
RangerMetrics_initialized = false;
RangerMetrics_run = true;
RangerMetrics_nextID = 0;
RangerMetrics_messageQueue = createHashMap;
// for debug, view messages in queue
// RangerMetrics_messageQueue apply {[_x, count _y]};
RangerMetrics_sendBatchHandle = scriptNull;

RangerMetrics_settings = createHashMap;
RangerMetrics_recordingSettings = createHashMap;

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", RangerMetrics_cbaPresent]] call RangerMetrics_fnc_log;
["Initializing v0.0.2"] call RangerMetrics_fnc_log;

// Create listener - extension calls are async, so we need to listen for the response
addMissionEventHandler [
    "ExtensionCallback",
    RangerMetrics_callback_fnc_callbackHandler
];

// Deinit to start fresh. See callback handler for the remainder of async init code
"RangerMetrics" callExtension "deinitExtension";



if (true) exitWith {};


[] spawn {
    sleep 1;
    isNil {


        // set up CBA class inits if CBA loaded
        call RangerMetrics_fnc_classHandlers;



        
    };
};

