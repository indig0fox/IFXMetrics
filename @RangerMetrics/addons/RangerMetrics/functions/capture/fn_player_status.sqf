if (!RangerMetrics_run) exitWith {};

params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
// _networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

private _settings = RangerMetrics_recordingSettings get "playerStatus";

[
	_settings get "bucket",
	_settings get "measurement",
	[["string", "playerUID", _playerUID]],
	[
		["int", "clientStateNumber", _clientState],
		["int", "adminState", _adminState],
		["string", "profileName", _profileName]
	],
	["server"]
] call RangerMetrics_fnc_queue;