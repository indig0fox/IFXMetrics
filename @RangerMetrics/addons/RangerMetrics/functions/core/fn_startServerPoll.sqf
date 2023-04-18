params ["_refName", "_code"];

private _intervalMs = RangerMetrics_recordingSettings get _refName get "intervalMs";
if (isNil "_intervalMs") exitWith {
    [format["No intervalMs found for serverPoll %1", _name]] call RangerMetrics_fnc_log;
};

private _interval = _intervalMs / 1000; // convert to seconds

// if interval is 0, just run once now at init
if (_interval == 0) exitWith {
    [_code] call CBA_fnc_execNextFrame;
};


private _handle = [{
    params ["_args", "_idPFH"];
    _args params ["_refName", "_code"];

    [_code] call CBA_fnc_execNextFrame;

}, _interval, _this] call CBA_fnc_addPerFrameHandler;

missionNamespace setVariable [
    "RangerMetrics" + "_serverPoll_" + _refName,
    _handle
];