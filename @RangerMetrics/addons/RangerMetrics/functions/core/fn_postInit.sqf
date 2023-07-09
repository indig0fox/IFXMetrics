// if (!isServer) exitWith {};

if (is3DEN || !isMultiplayer) exitWith {};
if (!isServer && hasInterface) exitWith {};


RangerMetrics = false call CBA_fnc_createNamespace;

RangerMetrics_cbaPresent = isClass(configFile >> "CfgPatches" >> "cba_main");
RangerMetrics_logPrefix = "RangerMetrics";
RangerMetrics_debug = false;
RangerMetrics_initialized = false;
RangerMetrics_run = true;

RangerMetrics_settings = createHashMap;
RangerMetrics_recordingSettings = createHashMap;

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", RangerMetrics_cbaPresent]] call RangerMetrics_fnc_log;
["Initializing v0.0.3"] call RangerMetrics_fnc_log;

// Create listener - extension calls are async, so we need to listen for the response
addMissionEventHandler [
    "ExtensionCallback",
    RangerMetrics_callback_fnc_callbackHandler
];

// Deinit to start fresh. See callback handler for the remainder of async init code
"RangerMetrics" callExtension "initExtension";
