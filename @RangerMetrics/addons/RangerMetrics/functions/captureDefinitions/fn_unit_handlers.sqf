params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};
if (!isPlayer _unit) exitWith {};


// if ACE medical is running, remoteExec a Dammaged EH for the player's machine to send lastDamageSource from ACE to the server. this is used for EntityKilled EH and others.
if (RangerMetrics_aceMedicalPresent) then {
	[_unit, {
		params ["_unit"];
		private _handle = _unit addEventHandler ["Dammaged", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			private _aceLastDamage = _unit getVariable "ace_medical_lastDamageSource";
			if (!isNil "_aceLastDamage") then {
				_unit setVariable ["ace_medical_lastDamageSource", _aceLastDamage, 2];
			};
		}];
		_unit setVariable [
			"RangerMetrics_UNITEH_Dammaged",
			_handle
		];
	}] remoteExec ["call", owner _unit];
};


// explosion damage handler
[_unit, {
	params ["_unit"];
	private _handle = _unit addEventHandler ["Explosion", {
		// params ["_vehicle", "_damage", "_source"];
		_this remoteExec [
			"RangerMetrics_event_fnc_Explosion", 2
		];
	}];

	_unit setVariable [
		"RangerMetrics_UNITEH_Explosion",
		_handle
	];
}] remoteExec ["call", 0, _unit];


// TODO
// server HitPart EH
// https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HitPart
// _handle = _unit addEventHandler ["HitPart", {
// 	(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
// 	private _unitPlayerId = getPlayerId _unit;
// 	private _userInfo = getUserInfo _unitPlayerId;
// 	// workaround from wiki to get shooter playerUID
// 	if (isNull _projectile) exitWith {};
// 	private _shooterPlayerId = (getPlayerId (getShotParents _projectile select 1));
// 	private _shooterInfo = getUserInfo _shooterPlayerId;
	
// 	[
// 		"player_events",
// 		"HandleDamage",
// 		[
// 			["string", "playerUID", _userInfo select 2]
// 		],
// 		[
// 			["string", "selection", _selection],
// 			["number", "damage", _damage],
// 			["number", "hitIndex", _hitIndex],
// 			["string", "hitPoint", _hitPoint],
// 			["string", "shooter", _shooterInfo select 2],
// 			["string", "projectile", _projectile]
// 		],
// 		["server"]
// 	] call RangerMetrics_fnc_queue;

// 	[_unit] call RangerMetrics_capture_fnc_unit_state;
// }];

_handle = _unit addEventHandler [
	"FiredMan", RangerMetrics_event_fnc_FiredMan
];
_unit setVariable [
	"RangerMetrics_UNITEH_FiredMan",
	_handle
];

_handle = _unit addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;
	private _playerUID = "-1";
	if (!isNil "_userInfo") then {
		_playerUID = _userInfo select 2;
	};

	[
		"player_events",
		"GetInMan",
		[
			["string", "playerUID", _playerUID]
		],
		[
			["string", "role", _role],
			["string", "vehicle", _vehicle],
			["string", "turret", _turret]
		],
		["server"]
	] call RangerMetrics_fnc_queue;

	[_unit] call RangerMetrics_capture_fnc_unit_state;
}];
_unit setVariable [
	"RangerMetrics_UNITEH_GetInMan",
	_handle
];

_handle = _unit addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;
	private _playerUID = "-1";
	if (!isNil "_userInfo") then {
		_playerUID = _userInfo select 2;
	};

	[
		"player_events",
		"GetOutMan",
		[
			["string", "playerUID", _playerUID]
		],
		[
			["string", "role", _role],
			["string", "vehicle", _vehicle],
			["string", "turret", _turret]
		],
		["server"]
	] call RangerMetrics_fnc_queue;

	[_unit] call RangerMetrics_capture_fnc_unit_state;
}];
_unit setVariable [
	"RangerMetrics_UNITEH_GetOutMan",
	_handle
];

_handle = _unit addEventHandler ["HandleScore", {
	params ["_unit", "_object", "_score"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;
	private _playerUID = "-1";
	if (!isNil "_userInfo") then {
		_playerUID = _userInfo select 2;
	};

	[
		"player_events",
		"HandleScore",
		[
			["string", "playerUID", _playerUID]
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
_unit setVariable [
	"RangerMetrics_UNITEH_HandleScore",
	_handle
];


_handle = _unit addEventHandler ["InventoryClosed", {
	params ["_unit", "_container"];
	private _unitPlayerId = getPlayerId _unit;
	private _userInfo = getUserInfo _unitPlayerId;
	private _playerUID = "-1";
	if (!isNil "_userInfo") then {
		_playerUID = _userInfo select 2;
	};

	[
		"player_events",
		"InventoryClosed",
		[
			["string", "playerUID", _playerUID]
		],
		[
			["string", "container", _container]
		],
		["server"]
	] call RangerMetrics_fnc_queue;

	[_unit] call RangerMetrics_capture_fnc_unit_inventory;
	nil;
}];
_unit setVariable [
	"RangerMetrics_UNITEH_InventoryClosed",
	_handle
];

true;