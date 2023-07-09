params [
	["_unit", objNull],
	"_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"
];

if (isNull _unit) exitWith {};
private _unitPlayerId = getPlayerId _unit;
private _userInfo = getUserInfo _unitPlayerId;

[
	"player_events",
	"FiredMan",
	[
		["string", "playerUID", _userInfo select 2]
	],
	[
		["string", "weapon", _weapon],
		["string", "muzzle", _muzzle],
		["string", "mode", _mode],
		["string", "ammo", _ammo],
		["string", "magazine", _magazine],
		// ["object", "projectile", _projectile],
		["string", "vehicle", [configOf _vehicle] call displayName],
		["string", "vehicleClass", typeOf _vehicle]
	],
	["server"]
] call RangerMetrics_fnc_send;