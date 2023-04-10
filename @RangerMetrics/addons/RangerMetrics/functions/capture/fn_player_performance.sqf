if (!RangerMetrics_run) exitWith {};

{
	_x params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
	_networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

	[
		"player_state",
		"player_performance", 
		[["string", "playerUID", _playerUID]], 
		[
			["float", "avgPing", _avgPing],
			["float", "avgBandwidth", _avgBandwidth],
			["float", "desync", _desync]
		],
		["server"]
	] call RangerMetrics_fnc_queue;
} forEach (allUsers apply {getUserInfo _x});

