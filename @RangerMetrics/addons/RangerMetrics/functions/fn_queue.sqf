params [
    ["_bucket", "default", [""]],
    "_measurement",
    ["_tags", nil, [[], nil]],
    ["_fields", nil, [[], nil]],
    "_valueType",
    "_value"
];

private _profileName = profileName;
private _prefix = "Arma3";

private _extSend = [
    _measurement, // metric name
    _valueType, // float or int or bool
];

private _outTags = [ // tags
    ["profile", _profileName],
    ["world", toLower worldName]
];

if (!isNil "_tags") then {
    {
        _outTags pushBack [_x#0, _x#1];
    } forEach _tags;
};

_extSend pushBack (_outTags apply {format["tag|%1|%2", _x#0, _x#1]});

_outFields = [ // fields
    ["server", serverName],
    ["mission", missionName],
    ["value", _value]
];

if (!isNil "_fields") then {
    {
        _outFields pushBack [_x#0, _x#1];
    } forEach _fields;
};

_extSend pushBack (_outFields apply {format["field|%1|%2", _x#0, _x#1]});

// add to queue
(RangerMetrics_messageQueue getOrDefault [_bucket, [], true]) pushBack (flatten _extSend);

true
