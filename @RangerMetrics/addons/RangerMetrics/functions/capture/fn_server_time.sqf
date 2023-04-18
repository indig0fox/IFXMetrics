if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings get "serverTime";

[
	_settings get "bucket",
	_settings get "measurement",
	nil,
	[
		["float", "diag_tickTime", diag_tickTime toFixed 2],
		["float", "serverTime", time toFixed 2],
		["float", "timeMultiplier", timeMultiplier toFixed 2],
		["float", "accTime", accTime toFixed 2]
	]
] call RangerMetrics_fnc_queue;