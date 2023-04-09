// Number of global units
["server_state", "entities_global", nil, [
	["int", "units_alive", count allUnits ],
	["int", "units_dead", count allDeadMen],
	["int", "groups_total", count allGroups],
	["int", "vehicles_total", count vehicles]
]] call RangerMetrics_fnc_queue;