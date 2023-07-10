if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "serverPerformance";

[
	_settings getVariable "bucket",
	_settings getVariable "measurement",
	nil, [
	["float", "fps_avg", diag_fps toFixed 2],
	["float", "fps_min", diag_fpsMin toFixed 2]
]] call RangerMetrics_fnc_send;