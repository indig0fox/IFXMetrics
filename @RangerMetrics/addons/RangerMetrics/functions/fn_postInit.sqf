
// function adapted from YAINA by MartinCo at http://yaina.eu

// if (!isServer) exitWith {};
_cba = (isClass(configFile >> "CfgPatches" >> "cba_main"));

RangerMetrics_debug = true;

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", _cba]] call RangerMetrics_fnc_log;
["Initializing v1.1"] call RangerMetrics_fnc_log;

// _extData = "RangerMetrics" callExtension "loadSettings";
// if (_extData == "0") exitWith {
//     ["Extension not found, disabling"] call RangerMetrics_fnc_log;
//     RangerMetrics_run = false;
// };

// _extData = parseSimpleArray _extData;
// RangerMetrics_settingsDir = _extData select 0;
// RangerMetrics_settingsLoaded = _extData select 1;
// RangerMetrics_influxURL = _extData select 2;

// [format["InfluxDB URL: %1", RangerMetrics_influxURL]] call RangerMetrics_fnc_log;
// _extVersion = "RangerMetrics" callExtension "version";
// ["Extension version: " + _extVersion] call RangerMetrics_fnc_log;

addMissionEventHandler ["ExtensionCallback", {
    params ["_name", "_function", "_data"];
    if (_name == "RangerMetrics") then {
        [parseSimpleArray _data] call RangerMetrics_fnc_log;
    };
}];

// RangerMetrics_run = true;

// if(_cba) then { // CBA is running, use PFH
//     [RangerMetrics_fnc_run, 10, [_cba]] call CBA_fnc_addPerFrameHandler;
// } else { // CBA isn't running, use sleep
//     [_cba] spawn {
//         params ["_cba"];
//         while{true} do {
//             [[_cba]] call RangerMetrics_fnc_run; // nested to match CBA PFH signature
//             sleep 10;
//         };
//     };
// };
