if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "weather";

[
	_settings getVariable "bucket",
	_settings getVariable "measurement",
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
] call RangerMetrics_fnc_send;
