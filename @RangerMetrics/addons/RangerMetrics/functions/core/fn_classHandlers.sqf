if (!isServer) exitWith {};

if (!RangerMetrics_cbaPresent) exitWith {
	[
		format["RangerMetrics: CBA not present, aborting class EHs."],
		"WARN"
	] call RangerMetrics_fnc_log;
	false;
	
	// TODO: Add non-CBA compatibility for unit handler & id application
	// addMissionEventHandler ["EntityCreated", {
};

///////////////////////////////////////////////////////////////////////
// Initialize all units
///////////////////////////////////////////////////////////////////////

["Man", "InitPost", {
	params ["_unit"];
	[_unit] call RangerMetrics_cDefinitions_fnc_unit_handlers;

	_unit setVariable [
		"RangerMetrics_id",
		RangerMetrics_nextID,
		true
	];

	[_unit] call RangerMetrics_capture_fnc_unit_inventory;
	[_unit] call RangerMetrics_capture_fnc_unit_state;

	if (RangerMetrics_debug) then {
		[
			format["ID %1, Object %2 (%3)", RangerMetrics_nextID, _unit, [configOf _unit] call BIS_fnc_displayName],
			"DEBUG"
		] call RangerMetrics_fnc_log;
	};
	RangerMetrics_nextID = RangerMetrics_nextID + 1;
}, nil, nil, true] call CBA_fnc_addClassEventHandler;