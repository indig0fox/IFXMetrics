if (!RangerMetrics_run) exitWith {};

params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit", ["_jip", false]];
// _networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

private _fields = [
	["string", "playerID", _playerID],
	["string", "ownerId", _ownerId],
	["string", "playerUID", _playerUID],
	["string", "profileName", _profileName],
	["string", "displayName", _displayName],
	["string", "steamName", _steamName],
	["bool", "isHC", _isHC],
	["bool", "isJip", _jip]
];

// Role description
private _roleDescription = roleDescription _unit;
if (_roleDescription isNotEqualTo "") then {
	_fields pushBack ["string", "roleDescription", _roleDescription];
};

[
	"player_state",
	"player_identity",
	[
		["string", "playerUID", _playerUID]
	],
	_fields,
	["server"]
] call RangerMetrics_fnc_queue;
