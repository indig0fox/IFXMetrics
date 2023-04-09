// send the data

// duplicate the message queue so we can clear it before sending the data
private "_extSend";
isNil {
	_extSend = + RangerMetrics_messageQueue;
	RangerMetrics_messageQueue = createHashMap;
};


// debug
if (
	missionNamespace getVariable ["RangerMetrics_debug",false]
) then {
	[format ["Sending a3influx data: %1", _extSend], "DEBUG"] call RangerMetrics_fnc_log;
};

{
	private _bucket = _x;
	private _records = _y;

	while {count _records > 0} do {
		// extension calls support a max of 2048 elements in the extension call
		// so we need to split the data into chunks of 2000
		private "_processing";
		_processing = _records select [0, (count _records -1) min 2000];
		_records = _records select [2000, count _records - 1];

		// send the data
		if (
			missionNamespace getVariable ["RangerMetrics_debug",false]
		) then {
			[format ["Bucket: %1, RecordsCount: %2", _bucket, count _processing], "DEBUG"] call RangerMetrics_fnc_log;
		};

		"RangerMetrics" callExtension ["sendToInflux", flatten [_bucket, _processing]];
	};

} forEach _extSend;