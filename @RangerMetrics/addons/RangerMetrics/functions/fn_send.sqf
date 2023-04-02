params ["_metric", "_value", ["_global", false]];

private _profileName = profileName;
private _prefix = "Arma3";

private _metricPath = [format["%1,%2", _profileName, profileName], format["%1,%2", _profileName, "global"]] select _global;

// InfluDB settings
private _connection = "http://INFLUX_URL:8086";
private _token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXX_AUTH_TOKEN_XXXXXXXXXXXXXXXXXXXXXXXXXXX";
private _org = "XXX_INFLUX_ORG_XXXXXX";
private _bucket = "XXX_BUCKET_NAME";

private _extSend = format["%1,%2", format["%1,%2,%3,%4,%5,%6", _connection, _token, _org, _bucket, _metricPath, _metric], _value];

if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
    [format ["Sending a3influx data: %1", _extSend], "DEBUG"] call RangerMetrics_fnc_log;
};

// send the data
private _return = "a3influx" callExtension _extSend;

// shouldn't be possible, the extension should always return even if error
if(isNil "_return") exitWith {
    [format ["return was nil (%1)", _extSend], "ERROR"] call RangerMetrics_fnc_log;
    false
};

// extension error codes
if(_return in ["invalid metric value","malformed, could not find separator"] ) exitWith {
    [format ["%1 (%2)", _return, _extSend], "ERROR"] call RangerMetrics_fnc_log;
    false
};

// success, only show if debug is set
if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
    _returnArgs = _return splitString (toString [10,32]);
    [format ["a3influx return data: %1",_returnArgs], "DEBUG"] call RangerMetrics_fnc_log;
};

true
