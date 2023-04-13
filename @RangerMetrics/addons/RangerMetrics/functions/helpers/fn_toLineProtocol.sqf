params ["_line", ["_section", "field", [""]]];
_line params [
	["_valueType", "string", [""]],
	["_key", "", [""]],
	"_value"
];

// debug
// diag_log format["%1=%2", _key, _value];

if (isNil "_value") exitWith { 
	nil; 
};
if (_value isEqualTo "") exitWith { 
	nil
};

if (_value isEqualType []) then {
	_value = _value joinString ",";
	// replace double quotes with single quotes
	_value = [_value, '""', "'"] call RangerMetrics_fnc_stringReplace; 
};

_key = [_key, ',', "\,"] call RangerMetrics_fnc_stringReplace; 
_key = [_key, '=', "\="] call RangerMetrics_fnc_stringReplace; 
_key = [_key, ' ', "\ "] call RangerMetrics_fnc_stringReplace;

if (_section isEqualTo "tag") exitWith {
	switch (_valueType) do {
		case "string": {
			_value = [_value, ',', "\,"] call RangerMetrics_fnc_stringReplace; 
			_value = [_value, '=', "\="] call RangerMetrics_fnc_stringReplace; 
			_value = [_value, ' ', "\ "] call RangerMetrics_fnc_stringReplace;
			_value = format['%1=%2', _key, _value];
		};
		case "int": {
			_value = format['%1=%2i', _key, _value];
		};
		case "bool": {
			_value = format['%1=%2', _key, ['true', 'false'] select _value];
		};
		case "float": {
			_value = format['%1=%2', _key, _value];
		};
	};
	_value;
};

if (_section isEqualTo "field") exitWith {
	switch (_valueType) do {
		case "string": {
			_value = [_value, '\', "\\"] call RangerMetrics_fnc_stringReplace; 
			_value = [_value, '"', '\"'] call RangerMetrics_fnc_stringReplace;
			_value = format['%1="%2"', _key, _value];
		};
		case "int": {
			_value = format['%1=%2i', _key, _value];
		};
		case "bool": {
			_value = format['%1=%2', _key, ['true', 'false'] select _value];
		};
		case "float": {
			_value = format['%1=%2', _key, _value];
		};
	};
	_value;
};