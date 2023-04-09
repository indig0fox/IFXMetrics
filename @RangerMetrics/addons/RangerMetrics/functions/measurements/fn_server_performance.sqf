["server_state", "server_performance", nil, [
	["float", "avg", diag_fps toFixed 2],
	["float", "min", diag_fpsMin toFixed 2]
]] call RangerMetrics_fnc_queue;