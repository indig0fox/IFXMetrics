if (!RangerMetrics_run) exitWith {};

["server_state", "server_time", nil, [
	["float", "diag_tickTime", diag_tickTime toFixed 2],
	["float", "serverTime", time toFixed 2],
	["float", "timeMultiplier", timeMultiplier toFixed 2],
	["float", "accTime", accTime toFixed 2]
]] call RangerMetrics_fnc_queue;