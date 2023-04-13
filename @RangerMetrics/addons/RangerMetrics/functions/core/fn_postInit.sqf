// if (!isServer) exitWith {};

if (is3DEN || !isMultiplayer) exitWith {};
if (!isServer && hasInterface) exitWith {};

RangerMetrics_cbaPresent = isClass(configFile >> "CfgPatches" >> "cba_main");
RangerMetrics_aceMedicalPresent = isClass(configFile >> "CfgPatches" >> "ace_medical_status");
RangerMetrics_logPrefix = "RangerMetrics";
RangerMetrics_debug = true;
RangerMetrics_initialized = false;
RangerMetrics_run = false;
RangerMetrics_nextID = 0;
RangerMetrics_messageQueue = createHashMap;
// for debug, view messages in queue
// RangerMetrics_messageQueue apply {[_x, count _y]};
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
        ["org", _settingsLoaded#2]
    ]
];
RangerMetrics_settings set [
    "arma3",
    createHashMapFromArray [
        ["refreshRateMs", _settingsLoaded#3]
    ]
];


// connect to DB, extension is now ready
private _dbConnection = "RangerMetrics" callExtension "connectToInflux";
if (_dbConnection isEqualTo "") exitWith {
    ["Failed to connect to InfluxDB, disabling"] call RangerMetrics_fnc_log;
};

_response = parseSimpleArray _dbConnection;
(_response) call RangerMetrics_fnc_log;
systemChat str _response;

// send server profile name to all clients with JIP, so HC or player reporting knows what server it's connected to
if (isServer) then {
    ["RangerMetrics_serverProfileName", profileName] remoteExecCall ["setVariable", 0, true];
    RangerMetrics_serverProfileName = profileName;
};


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
    ],
    [
        "CBAEvent",
        call RangerMetrics_cDefinitions_fnc_server_CBA
    ]
];



// add missionEventHandlers on server only
{_x params ["_handleName", "_code"];
    if (!isServer) exitWith {};
    // try {
        _handle = (addMissionEventHandler [_handleName, _code]);
    // } catch {
        // _handle = nil;
    // };
    if (isNil "_handle") then {
        [format["Failed to add Mission event handler: %1", [_handleName]], "ERROR"] call RangerMetrics_fnc_log;
    } else {
        missionNamespace setVariable [
            ("RangerMetrics" + "_MEH_" + _handleName),
            _handle
        ];
        true;
    };
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


// set up CBA event listeners
{_x params ["_handleName", "_code"];
    private "_handle";
    // try {
        _handle = ([_handleName, _code] call CBA_fnc_addEventHandlerArgs);
    // } catch {
    //     _handle = nil;
    // };

    if (isNil "_handle") then {
        [format["Failed to add CBA event handler: %1", [_handleName, _code]], "ERROR"] call RangerMetrics_fnc_log;
    } else {
        missionNamespace setVariable [
            ("RangerMetrics" + "_CBAEH_" + _handleName),
            _handle
        ];
        true;
    };
} forEach (RangerMetrics_captureDefinitions get "CBAEvent");




[] spawn {
    sleep 1;
    isNil {
        addMissionEventHandler [
            "ExtensionCallback",
            RangerMetrics_fnc_callbackHandler
        ];

        // set up CBA class inits if CBA loaded
        call RangerMetrics_fnc_classHandlers;

        private _meh = allVariables missionNamespace select {
            _x find (toLower "RangerMetrics_MEH_") == 0
        };
        private _cba = allVariables missionNamespace select {
            _x find (toLower "RangerMetrics_CBAEH_") == 0
        };
        private _serverPoll = allVariables missionNamespace select {
            _x find (toLower "RangerMetrics_captureBatchHandle_") == 0
        };

        [format ["Mission event handlers: %1", _meh]] call RangerMetrics_fnc_log;
        [format ["CBA event handlers: %1", _cba]] call RangerMetrics_fnc_log;
        [format ["Server poll handles: %1", _serverPoll]] call RangerMetrics_fnc_log;

        RangerMetrics_initialized = true;
        RangerMetrics_run = true;
        ["RangerMetrics_run", true] remoteExecCall ["setVariable", 0];


        // start sending
        [{
            params ["_args", "_idPFH"];
            if (scriptDone RangerMetrics_sendBatchHandle) then {
                RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
            };
            // call RangerMetrics_fnc_send;
        }, 2, []] call CBA_fnc_addPerFrameHandler;
    };
};

