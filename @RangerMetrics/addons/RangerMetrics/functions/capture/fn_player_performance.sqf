if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "playerPerformance";

{
	_x params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
	_networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

	if (_unit == objNull || _isHC) then {
		continue;
	};

	[
		_settings getVariable "bucket",
		_settings getVariable "measurement", 
		[["string", "playerUID", _playerUID]], 
		[
			["float", "avgPing", _avgPing],
			["float", "avgBandwidth", _avgBandwidth],
			["float", "desync", _desync]
		],
		["server"]
	] call RangerMetrics_fnc_send;
} forEach (allUsers apply {getUserInfo _x});

