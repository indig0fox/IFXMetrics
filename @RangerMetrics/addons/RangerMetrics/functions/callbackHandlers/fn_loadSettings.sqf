params ["_function", "_data"];


if (_function isEqualTo "loadSettingsJSON") exitWith {
	diag_log "RangerMetrics: loadSettingsJSON";
	// diag_log text format["%1", _data#0];
	RangerMetrics_settings = [_data#0] call CBA_fnc_parseJSON;
	// diag_log text format["%1", RangerMetrics_settings];


	RangerMetrics_recordingSettings = RangerMetrics_settings getVariable "recordingSettings";

	RangerMetrics_debug = (RangerMetrics_settings getVariable "arma3") getVariable "debug";

	[
		"Settings loaded: %1",
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
			"DEBUG"
		] call RangerMetrics_fnc_log;

	};
	
	default {
		[
			_data select 0,
			"DEBUG"
		] call RangerMetrics_fnc_log;
	};
};
