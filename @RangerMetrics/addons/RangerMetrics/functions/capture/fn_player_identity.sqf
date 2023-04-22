if (!RangerMetrics_run) exitWith {};

params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit", ["_jip", false]];
// _networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

private _settings = RangerMetrics_recordingSettings get "playerIdentity";


private _fields = [
	["string", "playerID", _playerID],
	["int", "ownerId", _ownerId],
	["string", "playerUID", _playerUID],
	["string", "profileName", _profileName],
	["string", "displayName", _displayName],
	["string", "steamName", _steamName],
	["bool", "isHC", _isHC],
	["bool", "isJip", _jip]
];

try {
	// Get Squad Info of Player
	(squadParams _unit) params [
		"_squadInfo",
		"_unitInfo",
		"_squadId",
		"_a3unitsId"
	];

	// For each section, we'll define the format and save to fields
	_squadInfoDataFormat = [
		"squadNick",
		"squadName",
		"squadEmail",
		"squadWeb",
		"squadLogo",
		"squadTitle"
	];

	{
		_fields pushBack [
			"string",
			_squadInfoDataFormat select _forEachIndex,
			_squadInfo select _forEachIndex
		];
	} forEach _squadInfoDataFormat;

	_unitInfoDataFormat = [
		"unitUid",
		"unitName",
		"unitFullName",
		"unitICQ",
		"unitRemark"
	];

	{
		_fields pushBack [
			"string",
			_unitInfoDataFormat select _forEachIndex,
			_unitInfo select _forEachIndex
		];
	} forEach _unitInfoDataFormat;
} catch {
	// If we fail to get squad info, we'll just skip it
	[format["Failed to get squad info for %1", _playerUID]] call RangerMetrics_fnc_log;
};



// Role description
private _roleDescription = roleDescription _unit;
if (_roleDescription isNotEqualTo "") then {
	_fields pushBack ["string", "roleDescription", _roleDescription];
};

[
	_settings get "bucket",
	_settings get "measurement",
	[
		["string", "playerUID", _playerUID]
	],
	_fields,
	["server"]
] call RangerMetrics_fnc_queue;
