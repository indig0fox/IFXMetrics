params ["_name", "_function", "_data"];
if !(_name == "RangerMetrics") exitWith {};

// Validate data param
if (isNil "_data") then {_data = ""};

if (_data isEqualTo "") exitWith {
	[
		format ["Callback empty data: %1", _function],
		"WARN"
	] call RangerMetrics_fnc_log;
	false;
};

// Parse response from string array
private "_response";
try {
	diag_log format ["Raw callback: %1: %2", _function, _data];
	_response = parseSimpleArray _data;
} catch {
	[
		format ["Callback invalid data: %1: %2", _function, _data],
		"WARN"
	] call RangerMetrics_fnc_log;
};


switch (_function) do {
	case "deinitExtension": {
		diag_log format ["RangerMetrics: deinitExtension: %1", _response];
		// Our first call is deinitExtension. When we received a single "true" value, we can then run init processes for the extension connections.
		if ((_response select 0) isEqualTo true) then {
			"RangerMetrics" callExtension "initExtension";
		} else {
			_response call RangerMetrics_fnc_log;
		};
	};
	case "loadSettings": {
		// Load settings
		_response call RangerMetrics_callback_fnc_loadSettings;
	};
	default {
		_response call RangerMetrics_fnc_log;
	}
}
