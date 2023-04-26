if (!RangerMetrics_run) exitWith {};

params [["_unit", objNull], "_unconscious"];
if (isNull _unit) exitWith {};
if (!isPlayer _unit) exitWith {};
// Get owner playerUID
private _unitUID = getPlayerUID _unitUID;
if (_unitUID isEqualTo "") exitWith {false};

[
	"player_state",
	"player_health",
	[
		["string", "playerUID", _unitUID]
	],
	[
		["float", "health", 1 - (damage _unit)],
		["bool", "state", _unconscious]
	]
] call RangerMetrics_fnc_queue;

true;