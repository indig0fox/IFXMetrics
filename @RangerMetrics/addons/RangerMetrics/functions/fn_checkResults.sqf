
private _threadsToCheck = RangerMetrics_activeThreads;
{
	private _finished = ["RangerMetrics.influx.has_call_finished", [_threadId]] call py3_fnc_callExtension;
	if (_finished) then {
		_threadsToCheck = _threadsToCheck - [_threadId];
		if (missionNamespace getVariable ["RangerMetrics_debug",false]) then {
			private _return = ["RangerMetrics.influx.get_call_value", [_threadId]] call py3_fnc_callExtension;
			[format ["Thread result: %1", _extSend], "DEBUG"] call RangerMetrics_fnc_log;
		};
	};
} forEach _threadsToCheck;

