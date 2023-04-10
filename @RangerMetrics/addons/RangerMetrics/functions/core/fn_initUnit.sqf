params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};
if (!isPlayer _unit) exitWith {};


[RangerMetrics_aceMedicalPresent, {
	if (not _this) exitWith {};
	player addEventHandler ["Dammaged", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		private _aceLastDamage = _unit getVariable "ace_medical_lastDamageSource";
		if (!isNil "_aceLastDamage") then {
			_unit setVariable ["ace_medical_lastDamageSource", _aceLastDamage, 2];
		};
	}];
}] remoteExec ["call", owner _unit, _unit];

_unit addEventHandler ["Dammaged", {
	params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;
	private _shooterPlayerId = (getPlayerId (getShotParents _projectile select 1));
	private _shooterInfo = getUserInfo _shooterPlayerId;
	[_unit] call RangerMetrics_capture_fnc_unit_state;
	
	[
		"player_events",
		"Dammaged",
		[
			["string", "playerUID", _userInfo select 2]
		],
		[
			["string", "selection", _selection],
			["number", "damage", _damage],
			["number", "hitIndex", _hitIndex],
			["string", "hitPoint", _hitPoint],
			["string", "shooter", _shooterInfo select 2],
			["string", "projectile", _projectile]
		],
		["server"]
	] call RangerMetrics_fnc_queue;
}];

_unit addEventHandler ["FiredMan", {
	_this call RangerMetrics_event_fnc_FiredMan;
}];

_unit addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;

	[
		"player_events",
		"GetInMan",
		[
			["string", "playerUID", _userInfo select 2]
		],
		[
			["string", "role", _role],
			["string", "vehicle", _vehicle],
			["string", "turret", _turret]
		],
		["server"]
	] call RangerMetrics_fnc_queue;
}];

_unit addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;

	[
		"player_events",
		"GetOutMan",
		[
			["string", "playerUID", _userInfo select 2]
		],
		[
			["string", "role", _role],
			["string", "vehicle", _vehicle],
			["string", "turret", _turret]
		],
		["server"]
	] call RangerMetrics_fnc_queue;
}];

_unit addEventHandler ["HandleScore", {
	params ["_unit", "_object", "_score"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;

	[
		"player_events",
		"HandleScore",
		[
			["string", "playerUID", _userInfo select 2]
		],
		[
			["int", "score", _score],
			["string", "objectClass", typeOf _object],
			["string", "object", [configOf _object] call BIS_fnc_displayName]
		],
		["server"]
	] call RangerMetrics_fnc_queue;

	nil;
}];


// _unit addEventHandler ["InventoryClosed", {
// 	params ["_unit", "_container"];
// 	private _unitPlayerId = getPlayerId _unit;
// 	private _userInfo = getUserInfo _unitPlayerId;

// 	[
// 		"player_events",
// 		"InventoryClosed",
// 		[
// 			["string", "playerUID", _userInfo select 2]
// 		],
// 		[
// 			["string", "container", _container]
// 		],
// 		["server"]
// 	] call RangerMetrics_fnc_queue;
// }];