if (!RangerMetrics_run) exitWith {};

private _startTime = diag_tickTime;

call RangerMetrics_capture_fnc_server_performance;
call RangerMetrics_capture_fnc_running_scripts;
call RangerMetrics_capture_fnc_server_time;
call RangerMetrics_capture_fnc_weather;

call RangerMetrics_capture_fnc_entities_local;
call RangerMetrics_capture_fnc_entities_global;

private _allUsers = allUsers apply {getUserInfo _x};
{
    _x call RangerMetrics_capture_fnc_player_performance;
} forEach _allUsers;

// log the runtime and switch off debug so it doesn't flood the log
if (
    missionNamespace getVariable ["RangerMetrics_debug",false]
) then {
    [format ["Run time: %1", diag_tickTime - _startTime], "DEBUG"] call RangerMetrics_fnc_log;
    // missionNamespace setVariable ["RangerMetrics_debug",false];
};