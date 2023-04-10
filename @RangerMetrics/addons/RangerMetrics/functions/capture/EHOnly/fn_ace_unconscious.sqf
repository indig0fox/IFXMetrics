if (!RangerMetrics_run) exitWith {};

params [["_unit", objNull], "_unconscious"];
if (isNull _unit) exitWith {};

// Get owner playerUID
private _unitUID = getPlayerUID _unitUID;
if (_unitUID isEqualTo "") exitWith {};

[
	"player_state",
	"player_health",
	[
		["string", "playerUID", _unitUID]
	],
	[
		["int", "health", damage _unit],
		["bool", "state", _unconscious]
	]
] call RangerMetrics_fnc_queue;