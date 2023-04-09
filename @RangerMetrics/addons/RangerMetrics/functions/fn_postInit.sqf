// if (!isServer) exitWith {};
_cba = (isClass(configFile >> "CfgPatches" >> "cba_main"));

RangerMetrics_logPrefix = "RangerMetrics";
RangerMetrics_debug = true;
RangerMetrics_activeThreads = [];
RangerMetrics_messageQueue = createHashMap;

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", _cba]] call RangerMetrics_fnc_log;
["Initializing v1.1"] call RangerMetrics_fnc_log;

private _settingsLoaded = "RangerMetrics" callExtension "loadSettings";
// if (isNil "_settingsLoaded") exitWith {
//     ["Extension not found, disabling"] call RangerMetrics_fnc_log;
//     RangerMetrics_run = false;
// };
// if (_settingsLoaded isEqualTo []) then {
//     if (count _settingsLoaded == 0) exitWith {
//         ["Settings not loaded, disabling"] call RangerMetrics_fnc_log;
//         RangerMetrics_run = false;
//     };
//     if (_settingsLoaded#0 isEqualTo 1) exitWith {
//         [
//             format["Settings not loaded, disabling. %1", _settingsLoaded#1],
//             "ERROR"
//         ] call RangerMetrics_fnc_log;
//         RangerMetrics_run = false;
//     };
// };
format["Settings loaded: %1", _settingsLoaded#2] call RangerMetrics_fnc_log;
RangerMetrics_settings = _settingsLoaded#2;
// RangerMetrics_settings = createHashMap;
// private _top = createHashMapFromArray _settingsLoaded#2;
// RangerMetrics_settings set [
//     "influxDB",
//     createHashMapFromArray (_top get "influxDB")
// ];
// RangerMetrics_settings set [
//     "arma3",
//     createHashMapFromArray (_top get "refreshRateMs")
// ];
"RangerMetrics" callExtension "connectToInflux";

RangerMetrics_run = true;

// addMissionEventHandler ["ExtensionCallback", {
//     params ["_name", "_function", "_data"];
//     if (_name == "RangerMetrics") then {
//         [parseSimpleArray _data] call RangerMetrics_fnc_log;
//     };
// }];

if(_cba) then { // CBA is running, use PFH
    [{
        params ["_args", "_idPFH"];
        _args params [["_cba", false]];
        [_cba] call RangerMetrics_fnc_gather;
        call RangerMetrics_fnc_checkResults;
        call RangerMetrics_fnc_send;
    // }, (RangerMetrics_settings get "arma3" get "refreshRateMs"), [_cba]] call CBA_fnc_addPerFrameHandler;
    }, 1, [_cba]] call CBA_fnc_addPerFrameHandler;
} else { // CBA isn't running, use sleep
    [_cba] spawn {
        params ["_cba"];
        while {true} do {
            [_cba] call RangerMetrics_fnc_gather; // nested to match CBA PFH signature
            call RangerMetrics_fnc_checkResults;
            call RangerMetrics_fnc_send;
            // sleep (RangerMetrics_settings get "arma3" get "refreshRateMs");
            sleep 1;
        };
    };
};
