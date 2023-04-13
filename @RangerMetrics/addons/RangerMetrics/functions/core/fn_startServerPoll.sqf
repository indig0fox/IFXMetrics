params [
    ["_interval", 5, [0]],
    ["_functions", [], [[]]]
];

private _captureHandleName = format ["RangerMetrics_captureBatchHandle_%1", _interval];

if (RangerMetrics_cbaPresent) then { // CBA is running, use PFH

    /*

    This capture method is dynamic.
    Every 5 seconds, two script handles are checked. One is for capturing, one is for sending.
    The capturing script will go through and capture data, getting nanosecond precision timestamps from the extension to go alongside each data point, then saving it to a queue. It will go through all assigned interval-based checks then exit, and on the next interval of this parent PFH, the capturing script will be spawned again.
    The queue is a hashmap where keys are buckets and values are arrays of data points in [string] line protocol format.
    The sending script will go through and send data, sending it in batches per bucket and per 2000 data points, as the max extension call with args is 2048 elements.
    The sending script will also check if the queue is empty, and if it is, it will exit. This means scriptDone will be true, and on the next interval of this parent PFH, the sending script will be spawned again.


    This system means that capture and sending are occurring in the scheduled environment, not blocking the server, while maintaining the timestamps of when each point was captured. The cycles of each will only occur at most once per 2 seconds, leaving plenty of time, and there will never be more than one call for each at a time.
    */
    private _handle = [{
        params ["_args", "_idPFH"];
        _args params ["_captureHandleName", "_functions"];

        if (!RangerMetrics_run) exitWith {};

        // use spawn
        // if (scriptDone _captureHandleName) then {
        //     missionNamespace setVariable [
        //         _captureHandleName,
        //         [_functions] spawn {
        //             {
        //                 call _x;
        //             } forEach _this;
        //         }
        //     ];
        // };

        // call direct
        [format["Running %1 functions for %2", count _functions, _captureHandleName], "DEBUG"] call RangerMetrics_fnc_log;
        {
            _x params ["_whereToRun", "_scriptBlock"];
            if (
                _whereToRun find "server" == -1 &&
                !isServer
            ) exitWith {false};

            if (
                _whereToRun find "hc" == -1 &&
                (!hasInterface && !isDedicated)
            ) exitWith {false};

            [] spawn _scriptBlock;
        } forEach _functions;
    }, _interval, [_captureHandleName, _functions]] call CBA_fnc_addPerFrameHandler;
    
    missionNamespace setVariable [_captureHandleName, _handle];


} else { // CBA isn't running, use sleep
    [_interval, _functions] spawn {
        params ["_interval", "_functions"];
        while {true} do {
            if (!RangerMetrics_run) exitWith {};
			{
                _x  params ["_whereToRun", "_scriptBlock"];
                if (
                    _whereToRun find "server" == -1 &&
                    !isServer
                ) exitWith {false};

                if (
                    _whereToRun find "hc" == -1 &&
                    (!hasInterface && !isDedicated)
                ) exitWith {false};

                [] spawn _scriptBlock;
            } forEach _functions;

			sleep (_interval * 2);
        };
    };
};
