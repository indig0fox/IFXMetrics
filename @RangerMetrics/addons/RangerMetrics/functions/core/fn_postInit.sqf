// if (!isServer) exitWith {};

if (is3DEN || !isMultiplayer) exitWith {};

RangerMetrics_cbaPresent = (isClass(configFile >> "CfgPatches" >> "cba_main"));
RangerMetrics_logPrefix = "RangerMetrics";
RangerMetrics_debug = true;
RangerMetrics_initialized = false;
RangerMetrics_run = false;
RangerMetrics_activeThreads = [];
RangerMetrics_messageQueue = createHashMap;
RangerMetrics_sendBatchHandle = scriptNull;
RangerMetrics_captureBatchHandle = scriptNull;

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", RangerMetrics_cbaPresent]] call RangerMetrics_fnc_log;
["Initializing v0.1"] call RangerMetrics_fnc_log;


// load settings from extension / settings.json
private _settingsLoaded = "RangerMetrics" callExtension "loadSettings";
// if (isNil "_settingsLoaded") exitWith {
//     ["Extension not found, disabling"] call RangerMetrics_fnc_log;
//     RangerMetrics_run = false;
// };
if (_settingsLoaded isEqualTo [] || _settingsLoaded isEqualTo "") exitWith {
    ["Failed to load settings, exiting", "ERROR"] call RangerMetrics_fnc_log;
};
_settingsLoaded = parseSimpleArray (_settingsLoaded);
[format["Settings loaded: %1", _settingsLoaded]] call RangerMetrics_fnc_log;
RangerMetrics_settings = createHashMap;
RangerMetrics_settings set [
    "influxDB",
    createHashMapFromArray [
        ["host", _settingsLoaded#1],
        ["org", _settingsLoaded#2],
        ["defaultBucket", _settingsLoaded#3]
    ]
];
RangerMetrics_settings set [
    "arma3",
    createHashMapFromArray [
        ["refreshRateMs", _settingsLoaded#4]
    ]
];


// connect to DB, extension is now ready
private _dbConnection = "RangerMetrics" callExtension "connectToInflux";
if (_dbConnection isEqualTo "") exitWith {
    ["Failed to connect to InfluxDB, disabling"] call RangerMetrics_fnc_log;
};

(parseSimpleArray _dbConnection) call RangerMetrics_fnc_log;

// send server profile name to all clients with JIP, so HC or player reporting knows what server it's connected to
if (isServer) then {
    ["RangerMetrics_serverProfileName", profileName] remoteExecCall ["setVariable", 0, true];
    RangerMetrics_serverProfileName = profileName;
};


addMissionEventHandler ["ExtensionCallback", {
    _this call RangerMetrics_fnc_callbackHandler;
}];

RangerMetrics_initialized = true;
RangerMetrics_run = true;


call RangerMetrics_fnc_addHandlers;


if (RangerMetrics_cbaPresent) then { // CBA is running, use PFH

    /*

    This capture method is dynamic.
    Every 5 seconds, two script handles are checked. One is for capturing, one is for sending.
    The capturing script will go through and capture data, getting nanosecond precision timestamps from the extension to go alongside each data point, then saving it to a queue. It will go through all assigned interval-based checks then exit, and on the next interval of this parent PFH, the capturing script will be spawned again.
    The queue is a hashmap where keys are buckets and values are arrays of data points in [string] line protocol format.
    The sending script will go through and send data, sending it in batches per bucket and per 2000 data points, as the max extension call with args is 2048 elements.
    The sending script will also check if the queue is empty, and if it is, it will exit. This means scriptDone will be true, and on the next interval of this parent PFH, the sending script will be spawned again.


    This system means that capture and sending are occurring in the scheduled environment, not blocking the server, while maintaining the timestamps of when each point was captured. The cycles of each will only occur at most once per 5 seconds, leaving plenty of time, and there will never be more than one call for each at a time.
    */
    [{
        params ["_args", "_idPFH"];
        if (scriptDone RangerMetrics_captureBatchHandle) then {
            RangerMetrics_captureBatchHandle = [] spawn RangerMetrics_fnc_captureLoop;
        };
        if (scriptDone RangerMetrics_sendBatchHandle) then {
            RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
        };
    }, 5, []] call CBA_fnc_addPerFrameHandler;


    // runs on interval
    // [{
    //     params ["_args", "_idPFH"];
    //     RangerMetrics_unixTime = (parseSimpleArray ("RangerMetrics" callExtension "getUnixTimeNano")) select 0;
    //     // spawn RangerMetrics_fnc_captureLoop;
    //     // call RangerMetrics_fnc_send;
    // }, 3, []] call CBA_fnc_addPerFrameHandler;
} else { // CBA isn't running, use sleep
    [] spawn {
        while {true} do {
            RangerMetrics_unixTime = (parseSimpleArray ("RangerMetrics" callExtension "getUnixTimeNano")) select 0;
            call RangerMetrics_fnc_captureLoop; // nested to match CBA PFH signature

            sleep 1;
            if (RangerMetrics_sendBatchHandle != -1) exitWith {
                RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
            };
            if (scriptDone RangerMetrics_sendBatchHandle) exitWith {
                RangerMetrics_sendBatchHandle = -1;
            };
        };
    };
};
