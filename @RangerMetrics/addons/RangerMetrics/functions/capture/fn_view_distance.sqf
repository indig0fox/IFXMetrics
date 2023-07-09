if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings get "viewDistance";

[
	_settings get "bucket",
	_settings get "measurement",
	nil,
	[
		["float", "objectViewDistance", getObjectViewDistance # 0],
		["float", "viewDistance", viewDistance]
	]
] call RangerMetrics_fnc_send;