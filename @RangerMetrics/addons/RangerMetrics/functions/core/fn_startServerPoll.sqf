params ["_refName", "_code"];

private _intervalMs = (RangerMetrics_recordingSettings getVariable _refName) getVariable ["intervalMs", 1000];
if (isNil "_intervalMs") exitWith {
    [format["No intervalMs found for serverPoll %1", _name]] call RangerMetrics_fnc_log;
};

private _interval = _intervalMs / 1000; // convert to seconds

// if interval is 0, just run once now at init
if (_interval == 0) exitWith {
    [_code] call CBA_fnc_execNextFrame;
};

// run a constant scheduled loop
// private _runnerVar = "RangerMetrics" + "_serverPollRunner_" + _refName;
// missionNamespace setVariable [_runnerVar, scriptNull];
// private _spawnParams = [_refName, _code, _interval, _runnerVar];
// private _handle = _spawnParams spawn {
//     params ["_refName", "_code", "_interval", "_runnerVar"];
//     while {true} do {
//         if (scriptDone (
//             missionNamespace getVariable _runnerVar
//         )) then {
//             private _handle = [] spawn _code;
//             missionNamespace setVariable [
//                 _runnerVar,
//                 _handle
//             ];
//         };
//         // sleep _interval;
//         sleep 2;
//     };
// };
// missionNamespace setVariable [
//     "RangerMetrics" + "_serverPoll_" + _refName,
//     _handle
// ];

// USE PFH
private _handle = [{
    params ["_args", "_idPFH"];
    _args params ["_refName", "_code"];

    [_code] call CBA_fnc_execNextFrame;

}, _interval, _this] call CBA_fnc_addPerFrameHandler;

missionNamespace setVariable [
    "RangerMetrics" + "_serverPoll_" + _refName,
    _handle
];