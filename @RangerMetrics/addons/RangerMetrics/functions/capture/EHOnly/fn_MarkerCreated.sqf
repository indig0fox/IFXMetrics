if (!RangerMetrics_run) exitWith {};

params ["_marker", "_channelNumber", "_owner", "_local"];

// Log marker
if (_marker isEqualTo "") exitWith {};
if (_channelNumber isEqualTo "") exitWith {};
if (_owner isEqualTo "") exitWith {};

// Get marker
private _markerData = _marker call BIS_fnc_markerToString;

// Get owner playerUID
private _ownerUID = getPlayerUID _owner;
if (_ownerUID isEqualTo "") then {
	_ownerUID = "-1";
};

[
	"server_events",
	"MarkerCreated",
	[
		["string", "actorPlayerUID", _ownerUID]
	],
	[
		["string", "marker", _markerData],
		["number", "channelNumber", _channelNumber],
		["string", "owner", _ownerUID]
	]
] call RangerMetrics_fnc_queue;
