// send the data

// duplicate the message queue so we can clear it before sending the data
private "_extSend";
// isNil {
// 	_extSend = + RangerMetrics_messageQueue;
// 	RangerMetrics_messageQueue = createHashMap;
// };


// debug
if (
	missionNamespace getVariable ["RangerMetrics_debug",false]
) then {
	["Sending a3influx data", "DEBUG"] call RangerMetrics_fnc_log;
};

{
	// run in direct unscheduled call
	// prevents race condition accessing hashmap
	isNil {
		private _bucket = _x;
		private _batchSize = 2000;

		// get the records for this bucket
		private "_records";
		private _records = RangerMetrics_messageQueue get _bucket;

		// send the data in chunks
		private _processing = _records select [0, (count _records -1) min _batchSize];

		RangerMetrics_messageQueue set [
			_bucket,
			(RangerMetrics_messageQueue get _bucket) - _processing
		];

		// send the data
		if (
			missionNamespace getVariable ["RangerMetrics_debug",false]
		) then {
			[format ["Bucket: %1, RecordsCount: %2", _bucket, count _processing], "DEBUG"] call RangerMetrics_fnc_log;

			// get unique measurement IDs
			private _measurements = [];
			{
				_thisMeasurement = _x splitString "," select 0;
				_measurements pushBackUnique _thisMeasurement;
			} forEach _processing;

			// get counts of each measurement
			private _measurementCounts = [];
			{
				private _measurement = _x;
				_measurementCounts pushBack [
					_measurement,
					count (_measurements select {_x == _measurement})
				];
			} forEach _measurements;

			[format ["Measurements: %1", _measurementCounts], "DEBUG"] call RangerMetrics_fnc_log;
		};

		"RangerMetrics" callExtension ["sendToInflux", flatten [_bucket, _processing]];
	};

} forEach (keys RangerMetrics_messageQueue);