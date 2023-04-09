params [
	["_valueType", "string", [""]],
	"_key",
	"_value"
];

// debug
// diag_log format["%1=%2", _key, _value];

if (_value isEqualTo "") exitWith { 
	""; 
};  
if (_valueType isEqualTo "string") exitWith { 
	format['%1="%2"', _key, _value];
}; 
 
format['%1=%2', _key, _value];
