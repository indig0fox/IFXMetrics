private _data = _this;

switch (_data select 0) do {
	case "CREATED SETTINGS": {
		[
			"settings.json did not exist and has been created - you will need to update it with your own settings before the addon will initialize further.",
			"ERROR"
		] call RangerMetrics_fnc_log;
	};
	case "SETTINGS LOADED": {

		RangerMetrics_settings = createHashMapFromArray (_data # 1);
		[
			format [
				"Settings loaded successfully from JSON. %1",
				RangerMetrics_settings
			],
			"INFO"
		] call RangerMetrics_fnc_log;

		// send server profile name to all clients with JIP, so HC or player reporting knows what server it's connected to
		if (isServer) then {
			["RangerMetrics_serverProfileName", profileName] remoteExecCall ["setVariable", 0, true];
			RangerMetrics_serverProfileName = profileName;
		};
	};
	default {
		[
			_data select 0,
			"INFO"
		] call RangerMetrics_fnc_log;
	};
};