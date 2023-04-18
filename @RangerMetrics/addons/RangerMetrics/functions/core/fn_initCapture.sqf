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
	private _settings = RangerMetrics_recordingSettings get _name;
	if (isNil "_settings") exitWith {};
	if (count (keys _settings) == 0) exitWith {};

	if (
		(_settings get "enabled") isNotEqualTo true ||
		(
			!isServer &&
			(_settings get "serverOnly") isNotEqualTo false
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
	
		private _settings = RangerMetrics_recordingSettings get "CBAEventHandlers" get _settingName;
	if (isNil "_settings") exitWith {};
	if (count (keys _settings) == 0) exitWith {};

	if (
		(_settings get "enabled") isNotEqualTo true ||
		(
			!isServer &&
			(_settings get "serverOnly") isNotEqualTo false
		) ||
		(hasInterface && !isServer)
	) exitWith {};

	_handle = ([_handleName, _code] call CBA_fnc_addEventHandlerArgs);

    if (isNil "_handle") then {
        [format["Failed to add CBA event handler: %1", _x], "ERROR"] call RangerMetrics_fnc_log;
		false;
    } else {
        missionNamespace setVariable [
            ("RangerMetrics" + "_CBAEH_" + _settingName),
            _handle
        ];
        true;
    };
} forEach (call RangerMetrics_cDefinitions_fnc_server_CBA);






private _meh = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_MEH_") == 0
};
private _cba = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_CBAEH_") == 0
};
private _serverPoll = allVariables missionNamespace select {
	_x find (toLower "RangerMetrics_serverPoll_") == 0
};

[format ["Mission event handlers: %1", _meh]] call RangerMetrics_fnc_log;
[format ["CBA event handlers: %1", _cba]] call RangerMetrics_fnc_log;
[format ["Server poll handles: %1", _serverPoll]] call RangerMetrics_fnc_log;


RangerMetrics_initialized = true;
RangerMetrics_run = true;
["RangerMetrics_run", true] remoteExecCall ["setVariable", 0];


// start sending
[{
	params ["_args", "_idPFH"];
	if (scriptDone RangerMetrics_sendBatchHandle) then {
		RangerMetrics_sendBatchHandle = [] spawn RangerMetrics_fnc_send;
	};
	// call RangerMetrics_fnc_send;
}, 2, []] call CBA_fnc_addPerFrameHandler;