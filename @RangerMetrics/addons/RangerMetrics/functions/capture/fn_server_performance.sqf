if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings get "serverPerformance";

[
	_settings get "bucket",
	_settings get "measurement",
	nil, [
	["float", "fps_avg", diag_fps toFixed 2],
	["float", "fps_min", diag_fpsMin toFixed 2]
]] call RangerMetrics_fnc_queue;