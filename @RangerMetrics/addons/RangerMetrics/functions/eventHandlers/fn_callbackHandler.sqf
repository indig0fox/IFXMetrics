params ["_name", "_function", "_data"];
if (_name == "RangerMetrics") then {
	if (isNil "_data") then {_data = ""};
	try {
		if (_data isEqualType "") exitWith {
			_data = parseSimpleArray _data;
			_data call RangerMetrics_fnc_log;
		};
		
		diag_log format ["Callback unsupported type: %1: %2", _function, _data];
	} catch {
		_data = format ["%1", _data];
	};
};