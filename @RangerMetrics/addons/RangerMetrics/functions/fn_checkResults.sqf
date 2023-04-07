{
	private _threadId = _x;
	private _finished = ["RangerMetrics.influx.has_call_finished", [_threadId]] call py3_fnc_callExtension;
	// systemChat str _finished;
	if (isNil "_finished") exitWith {
		RangerMetrics_activeThreads = RangerMetrics_activeThreads - [_threadId];
		[format ["[%1]: Thread %2 not found", RangerMetrics_logPrefix, _threadId], "WARN"] call RangerMetrics_fnc_log;
	};
	if (_finished isEqualTo []) exitWith {
		RangerMetrics_activeThreads = RangerMetrics_activeThreads - [_threadId];
		[format ["[%1]: Thread %2 not found", RangerMetrics_logPrefix, _threadId], "WARN"] call RangerMetrics_fnc_log;
	};
	
	if (_finished isEqualTo true) then {
		RangerMetrics_activeThreads = RangerMetrics_activeThreads - [_threadId];
		if (missionNamespace getVariable ["RangerMetrics_debug",false]) then {
			private _return = ["RangerMetrics.influx.get_call_value", [_threadId]] call py3_fnc_callExtension;
			[format ["%1", _return], "DEBUG"] call RangerMetrics_fnc_log;
		};
	};
} forEach RangerMetrics_activeThreads;

