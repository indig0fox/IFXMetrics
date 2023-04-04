params ["_metric", "_valueType", "_value", ["_global", false]];

private _profileName = profileName;
private _prefix = "Arma3";
private _locality = [profileName, "global"] select _global;

// InfluxDB settings
// private _connection = "http://indifox.info:8086";
// private _token = "BwOzapPBLZ-lhtrcs3PC2Jk2p7plCC0UckHKxe8AxulYkk9St1q2aloXMW2rDD4X2ufIkx3fwSbEe6ZeJo8ljg==";
// private _org = "ranger-metrics";
// private _bucket = "ranger-metrics";

// private _extSend = format["%1,%2", format["%1,%2,%3,%4,%5,%6", _connection, _token, _org, _bucket, _metricPath, _metric], _value];
private _extSend = [
    // _connection,
    // _token,
    // _org,
    // _bucket,
    _profileName,
    _locality,
    missionName,
    worldName,
    serverName,
    _metric,
    _valueType,
    _value
];

if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
    [format ["Sending a3influx data: %1", _extSend], "DEBUG"] call RangerMetrics_fnc_log;
};

// send the data
private _return = "RangerMetrics" callExtension ["sendToInflux", _extSend];

// shouldn't be possible, the extension should always return even if error
if(isNil "_return") exitWith {
    [format ["return was nil (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
    false
};

// extension error codes
// if(_return in ["invalid metric value","malformed, could not find separator"] ) exitWith {
//     [format ["%1 (%2)", _return, _extSend], "ERROR"] call RangerMetrics_fnc_log;
//     false
// };

// success, only show if debug is set
if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
    // _returnArgs = _return splitString (toString [10,32]);
    _returnArgs = parseSimpleArray _return;
    [format ["a3influx return data: %1",_returnArgs], "DEBUG"] call RangerMetrics_fnc_log;
};

true
