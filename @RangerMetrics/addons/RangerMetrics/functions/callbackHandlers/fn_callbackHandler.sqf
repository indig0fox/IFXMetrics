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
	// diag_log format ["Raw callback: %1: %2", _function, _data];
	if (_function find "JSON" > -1) then {
		_response = [_data, 2] call CBA_fnc_parseJSON;
	} else {
		_response = parseSimpleArray _data;
	};
} catch {
	[
		format ["Callback invalid data: %1: %2", _function, _data],
		"WARN"
	] call RangerMetrics_fnc_log;
};


switch (_function) do {
	case "deinitExtension": {
		// Our first call is deinitExtension. When we received a single "true" value, we can then run init processes for the extension connections.
		if ((_response select 0) isEqualTo true) then {
			"RangerMetrics" callExtension "initExtension";
		} else {
			_response call RangerMetrics_fnc_log;
		};
	};
	case "loadSettingsJSON": {
		[_function, _response] call RangerMetrics_callback_fnc_loadSettings;
	};
	case "loadSettings": {
		// Load settings
		[_function, _response] call RangerMetrics_callback_fnc_loadSettings;
	};
	case "extensionReady": {
		// deinitialize existing captures
		if (!isNil "RangerMetrics_allMEH") then {
			{
				private _handle = missionNamespace getVariable _x;
				if (isNil "_handle") then {continue};
				private _EHName = (_x splitString "_") select 2;
				removeMissionEventHandler [_EHName, _handle];
				missionNamespace setVariable [_x, nil];
			} forEach RangerMetrics_allMEH;
		};

		if (!isNil "RangerMetrics_allCBA") then {
			{
				private _handle = missionNamespace getVariable _x;
				if (isNil "_handle") then {continue};
				private _EHName = (_x splitString "_") select 2;
				[_EHName, _handle] call CBA_fnc_removeEventHandler;
				missionNamespace setVariable [_x, nil];
			} forEach RangerMetrics_allCBA;
		};
		
		if (!isNil "RangerMetrics_allServerPoll") then {
			{
				private _handle = missionNamespace getVariable _x;
				if (isNil "_handle") then {continue};
				terminate _handle;
				missionNamespace setVariable [_x, nil];
			} forEach RangerMetrics_allServerPoll;
		};

		call RangerMetrics_fnc_initCapture;
	};
	default {
		_response call RangerMetrics_fnc_log;
	};
};