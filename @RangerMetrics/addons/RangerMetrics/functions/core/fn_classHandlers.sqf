if (!RangerMetrics_cbaPresent) exitWith {
	[
		format["RangerMetrics: CBA not present, aborting class EHs."],
		"WARN"
	] call RangerMetrics_fnc_log;
};

///////////////////////////////////////////////////////////////////////
// Initialize all units
///////////////////////////////////////////////////////////////////////
["All", "InitPost", {
	private _unit = _this # 0;


	if (_unit isKindOf "CAManBase" && isPlayer _unit) then {
		[_unit] call RangerMetrics_fnc_initUnit;
	};


	_unit setVariable ["RangerMetrics_id", RangerMetrics_nextID, true];

	if (RangerMetrics_debug) then {
		[
			format["ID %1, Object %2 (%3)", RangerMetrics_nextID, _unit, [configOf _unit] call BIS_fnc_displayName],
			"DEBUG"
		] call RangerMetrics_fnc_log;
	};
	RangerMetrics_nextID = RangerMetrics_nextID + 1;
}, nil, nil, true] call CBA_fnc_addClassEventHandler;