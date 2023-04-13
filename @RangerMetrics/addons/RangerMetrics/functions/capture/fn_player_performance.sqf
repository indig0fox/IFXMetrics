if (!RangerMetrics_run) exitWith {};

private _settings = "recordingSettings.serverPolling.userPerformance" call RangerMetrics_fnc_getSetting;
if (!_settings) exitWith {
	[format["Error in settings lookup: %1", _settingsPath]] call RangerMetrics_fnc_log;
};

if !(_settings get "enabled") exitWith {false};

{
	_x params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
	_networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

	[
		_settings get "bucket",
		_settings get "measurement", 
		[["string", "playerUID", _playerUID]], 
		[
			["float", "avgPing", _avgPing],
			["float", "avgBandwidth", _avgBandwidth],
			["float", "desync", _desync]
		],
		["server"]
	] call RangerMetrics_fnc_queue;
} forEach (allUsers apply {getUserInfo _x});

