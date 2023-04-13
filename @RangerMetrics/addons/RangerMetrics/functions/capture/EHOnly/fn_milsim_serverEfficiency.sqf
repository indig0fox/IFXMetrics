params ["_fields", []];

// Example:
// [
//     ["float", "milsim_raw_cps", "3207.98"],
//     ["float", "milsim_cps", "1"]
// ]

[
	"server_state",
	"server_efficiency",
	nil,
	_fields,
	["server"]
] call RangerMetrics_fnc_queue;