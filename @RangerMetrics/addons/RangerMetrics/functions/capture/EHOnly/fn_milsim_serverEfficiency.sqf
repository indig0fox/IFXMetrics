params ["_fields", []];

// Example:
// [
//     ["float", "milsim_raw_cps", "3207.98"],
//     ["float", "milsim_cps", "1"]
// ]

private _settings = RangerMetrics_recordingSettings get "CBAEventHandlers" get "milsimServerEfficiency";

[
	_settings get "bucket",
	_settings get "measurement",
	nil,
	_fields,
	["server"]
] call RangerMetrics_fnc_queue;