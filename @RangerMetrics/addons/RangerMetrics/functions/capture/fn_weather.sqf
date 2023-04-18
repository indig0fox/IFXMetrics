if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings get "weather";

[
	_settings get "bucket",
	_settings get "measurement",
	nil, // tags
	[ // fields
		["float", "fog", fog],
		["float", "overcast", overcast],
		["float", "rain", rain],
		["float", "humidity", humidity],
		["float", "waves", waves],
		["float", "windDir", windDir],
		["float", "windStr", windStr],
		["float", "gusts", gusts],
		["float", "lightnings", lightnings],
		["float", "moonIntensity", moonIntensity],
		["float", "moonPhase", moonPhase date],
		["float", "sunOrMoon", sunOrMoon]
	]
] call RangerMetrics_fnc_queue;
