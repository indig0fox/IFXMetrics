if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "viewDistance";

[
	_settings getVariable "bucket",
	_settings getVariable "measurement",
	nil,
	[
		["float", "objectViewDistance", getObjectViewDistance # 0],
		["float", "viewDistance", viewDistance]
	]
] call RangerMetrics_fnc_send;