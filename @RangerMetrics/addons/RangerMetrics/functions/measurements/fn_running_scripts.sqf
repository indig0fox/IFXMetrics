["server_state", "running_scripts", nil, [
	["int", "spawn", diag_activeScripts select 0],
	["int", "execVM", diag_activeScripts select 1],
	["int", "exec", diag_activeScripts select 2],
	["int", "execFSM", diag_activeScripts select 3],
	["int", "pfh", if (RangerMetrics_cbaPresent) then {count CBA_common_perFrameHandlerArray} else {0}]
]] call RangerMetrics_fnc_queue;