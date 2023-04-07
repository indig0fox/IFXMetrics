// send the data
[{
	if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
		[format ["Sending a3influx data: %1", RangerMetrics_messageQueue], "DEBUG"] call RangerMetrics_fnc_log;
	};

	// duplicate the message queue so we can clear it before sending the data
	private _extSend = + RangerMetrics_messageQueue;
	RangerMetrics_messageQueue = createHashMap;

	{
		// for each bucket, send data to extension
		private _bucketName = _x;
		private _bucketData = _y;
		// if (true) exitWith {
			[format ["bucketName: %1", _bucketName], "DEBUG"] call RangerMetrics_fnc_log;
			[format ["bucketData: %1", _bucketData], "DEBUG"] call RangerMetrics_fnc_log;
		// };
		private _return = ["RangerMetrics.influx.write_influx", [[_bucketName, _bucketData]]] call py3_fnc_callExtension;

		// shouldn't be possible, the extension should always return even if error
		if(isNil "_return") exitWith {
			[format ["return was nil (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
			false
		};

		if (typeName _return != "ARRAY") exitWith {
			[format ["return was not an array (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
			false
		};

		if (count _return == 0) exitWith {
			[format ["return was empty (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
			false
		};

		if (count _return == 2) exitWith {
			[format ["return was error (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
			false
		};

		// success, add to list of active threads
		RangerMetrics_activeThreads pushBack (_return select 0);

		// success, only show if debug is set
		if (missionNamespace getVariable ["RangerMetrics_debug",false]) then {
			[format ["a3influx threadId: %1", _return], "DEBUG"] call RangerMetrics_fnc_log;
		};
	} forEach _extSend;
}] call CBA_fnc_execNextFrame;