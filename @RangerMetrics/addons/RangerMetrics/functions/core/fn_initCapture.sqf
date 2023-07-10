// MISSION EH
{
	if (!isServer) exitWith {};
	_x params ["_ehName", "_code"];

	_handle = (addMissionEventHandler [_ehName, _code]);
    if (isNil "_handle") then {
        [format["Failed to add Mission event handler: %1", _x], "ERROR"] call RangerMetrics_fnc_log;
		false;
    } else {
        missionNamespace setVariable [
            ("RangerMetrics" + "_MEH_" + _ehName),
            _handle
        ];
        true;
    };
} forEach (call RangerMetrics_cDefinitions_fnc_server_missionEH);

// SERVER POLLS
{
	// for each definition in SQF, pair it to the settings imported from settings.json
	// and then call the function to create the metric

	// get the definition
	_x params ["_name", "_code"];

	// get the settings
	private _settings = RangerMetrics_recordingSettings getVariable _name;
	if (isNil "_settings") exitWith {};
	if (count (allVariables _settings) == 0) exitWith {};

	if (
		(_settings getVariable "enabled") isNotEqualTo true ||
		(
			!isServer &&
			(_settings getVariable "serverOnly") isNotEqualTo false
		) ||
		(hasInterface && !isServer)
	) exitWith {};

	// set up pfh
	_x call RangerMetrics_fnc_startServerPoll;

} forEach (call RangerMetrics_cDefinitions_fnc_server_poll);


// CBA EVENTS
{
    private "_handle";
	_x params ["_settingName", "_handleName", "_code"];
	
		private _settings = (RangerMetrics_recordingSettings getVariable "CBAEventHandlers") getVariable _settingName;
	if (isNil "_settings") exitWith {};
	if (count (keys _settings) == 0) exitWith {};

	if (
		(_settings getVariable "enabled") isNotEqualTo true ||
		(
			!isServer &&
			(_settings getVariable "serverOnly") isNotEqualTo false
		) ||
		(hasInterface && !isServer)
	) exitWith {};

	_handle = ([_handleName, _code] call CBA_fnc_addEventHandlerArgs);

    if (isNil "_handle") then {
        [format["Failed to add CBA event handler: %1", _x], "ERROR"] call RangerMetrics_fnc_log;
		false;
    } else {
        missionNamespace setVariable [
            ("RangerMetrics" + "_CBAEH_" + _handleName),
            _handle
        ];
        true;
    };
} forEach (call RangerMetrics_cDefinitions_fnc_server_CBA);




RangerMetrics_allMEH = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_MEH_") == 0
};
RangerMetrics_allCBA = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_CBAEH_") == 0
};
RangerMetrics_allServerPoll = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_serverPoll_") == 0
};

[format ["Mission event handlers: %1", RangerMetrics_allMEH]] call RangerMetrics_fnc_log;
[format ["CBA event handlers: %1", RangerMetrics_allCBA]] call RangerMetrics_fnc_log;
[format ["Server poll handles: %1", RangerMetrics_allServerPoll]] call RangerMetrics_fnc_log;


missionNamespace setVariable ["RangerMetrics_initialized", true, true];
missionNamespace setVariable ["RangerMetrics_run", true, true];



// start sending
RangerMetrics_sendHandler = [{
	params ["_args", "_idPFH"];
	if !(
		missionNamespace getVariable [
			"RangerMetrics_run",
			false
		]
	) exitWith {};
	if (scriptDone RangerMetrics_sendBatchHandle) then {
		RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
	};
	// call RangerMetrics_fnc_send;
}, 2, []] call CBA_fnc_addPerFrameHandler;