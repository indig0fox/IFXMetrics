params ["_function", "_data"];


if (_function isEqualTo "loadSettingsJSON") exitWith {
	RangerMetrics_settings = _data;
	RangerMetrics_recordingSettings = _data get "recordingSettings";

	RangerMetrics_debug = RangerMetrics_settings get "arma3" get "debug";

	[
		format [
			"Settings loaded: %1",
			_data
		],
		"INFO"
	] call RangerMetrics_fnc_log;

	if (isServer) then {
		missionNamespace setVariable [
			"RangerMetrics_serverProfileName",
			profileName,
			true
		];
	};
};

switch (_data select 0) do {
	case "CREATED SETTINGS": {
		[
			"settings.json did not exist and has been created - you will need to update it with your own settings before the addon will initialize further.",
			"ERROR"
		] call RangerMetrics_fnc_log;
	};

	case "loadSettings": {
		[
			format [
				"Setting loaded: %1",
				_data
			],
			"INFO"
		] call RangerMetrics_fnc_log;

	};
	
	default {
		[
			_data select 0,
			"INFO"
		] call RangerMetrics_fnc_log;
	};
};
