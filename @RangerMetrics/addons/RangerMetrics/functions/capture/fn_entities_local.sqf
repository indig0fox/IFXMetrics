// Number of local units
["server_state", "entities_local", nil, [
	["int", "units_alive", { local _x} count allUnits ],
	["int", "units_dead", { local _x } count allDeadMen],
	["int", "groups_total", { local _x } count allGroups],
	["int", "vehicles_total", { local _x } count vehicles]
]] call RangerMetrics_fnc_queue;