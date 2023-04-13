if (!RangerMetrics_run) exitWith {};

["server_state", "server_performance", nil, [
	["float", "fps_avg", diag_fps toFixed 2],
	["float", "fps_min", diag_fpsMin toFixed 2]
]] call RangerMetrics_fnc_queue;