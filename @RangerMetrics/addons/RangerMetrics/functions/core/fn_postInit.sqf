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


// define the metrics to capture by sideloading definition files
// this keeps the main file clean and easy to read
// the definition files are in the format of a hashmap, where the key is the category and the value is an array of arrays, where each sub-array is a capture definition
RangerMetrics_captureDefinitions = createHashMapFromArray [
    [
        "ServerEvent",
        createHashMapFromArray [
            [
                "MissionEventHandlers",
                call RangerMetrics_cDefinitions_fnc_server_missionEH
            ]
    ]],
    ["ClientEvent", []],
    [
        "ServerPoll",
        call RangerMetrics_cDefinitions_fnc_server_poll
    ],
    [
        "ClientPoll",
        call RangerMetrics_cDefinitions_fnc_client_poll
    ]
];


// add missionEventHandlers on server
{_x params ["_handleName", "_code"];
    missionNamespace setVariable [
        ("RangerMetrics" + "_MEH_" + _handleName),
        (addMissionEventHandler [_handleName, _code])
    ];
} forEach ((RangerMetrics_captureDefinitions get "ServerEvent") get "MissionEventHandlers");

// begin server polling
{
    _x call RangerMetrics_fnc_startServerPoll;
} forEach (RangerMetrics_captureDefinitions get "ServerPoll");

// remoteExec client polling - send data to start handles
{
    _x call RangerMetrics_fnc_sendClientPoll;
} forEach (RangerMetrics_captureDefinitions get "ClientPoll");

// {

// } forEach (call RangerMetrics_captureDefinitions_fnc_clientEvent);

// begin client polling



// start sending
[{
    params ["_args", "_idPFH"];
    if (scriptDone RangerMetrics_sendBatchHandle) then {
        RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
    };
}, 2, []] call CBA_fnc_addPerFrameHandler;


RangerMetrics_initialized = true;
RangerMetrics_run = true;

call RangerMetrics_capture_fnc_running_mission;




