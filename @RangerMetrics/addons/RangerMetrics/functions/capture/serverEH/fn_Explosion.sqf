params ["_vehicle", "_damage", "_source"];

if (isNull _vehicle) exitWith {};
private _sourceClass = "";
private _sourceDisplayName = "";
private _sourcePlayerUID = "";
if !(isNull _source) then {
	private _sourceClass = typeOf _source;
	private _sourceDisplayName = [configOf _source] call BIS_fnc_displayName;
	if (isPlayer _source) then {
		private _sourcePlayerId = getPlayerId _source;
		private _sourceUserInfo = getUserInfo _sourcePlayerId;
		private _sourcePlayerUID = _sourceUserInfo select 2;
	} else {
		private _sourcePlayerUID = "";
	};
};
private _unitPlayerId = getPlayerId _vehicle;
private _userInfo = getUserInfo _unitPlayerId;
private _unitPlayerUID = _userInfo select 2;

[
	"player_events",
	"Explosion",
	[["string", "playerUID", _unitPlayerUID]],
	[
		["string", "sourceClass", _sourceClass],
		["string", "sourceDisplayName", _sourceDisplayName],
		["string", "sourcePlayerUID", _sourcePlayerUID],
		["float", "damage", _damage]
	],
	["server"]
] call RangerMetrics_fnc_queue;