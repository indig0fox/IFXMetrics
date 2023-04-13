if (!RangerMetrics_run) exitWith {};

params ["_marker", "_local"];

// Log marker
if (_marker isEqualTo "") exitWith {};

// Get marker
private _markerData = _marker call BIS_fnc_markerToString;

[
	"server_events",
	"MarkerUpdated",
	nil,
	[
		["string", "marker", _markerData]
	],
	["server"]
] call RangerMetrics_fnc_queue;

