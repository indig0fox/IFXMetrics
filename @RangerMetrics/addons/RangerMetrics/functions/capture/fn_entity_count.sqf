if (!RangerMetrics_run) exitWith {};

// Number of remote units
["server_state", "entities_remote", nil, [
	["int", "units_alive", { not (local _x)} count allUnits ],
	["int", "units_dead", { not (local _x) } count allDeadMen],
	["int", "groups_total", { not (local _x) } count allGroups],
	["int", "vehicles_total", { not (local _x) } count vehicles]
]] call RangerMetrics_fnc_queue;

// Number of local units
["server_state", "entities_local", nil, [
	["int", "units_alive", { local _x} count allUnits ],
	["int", "units_dead", { local _x } count allDeadMen],
	["int", "groups_total", { local _x } count allGroups],
	["int", "vehicles_total", { local _x } count vehicles]
]] call RangerMetrics_fnc_queue;

// Number of global units
["server_state", "entities_global", nil, [
	["int", "units_alive", count allUnits ],
	["int", "units_dead", count allDeadMen],
	["int", "groups_total", count allGroups],
	["int", "vehicles_total", count vehicles]
]] call RangerMetrics_fnc_queue;