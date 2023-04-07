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
    _valueType, // float or int
    [ // tags
        ["profile", _profileName],
        ["world", toLower worldName]
    ],
    [ // fields
        ["server", serverName],
        ["mission", missionName],
        ["value", _value]
    ]
];

if (!isNil "_tags") then {
    {
        (_extSend select 2) pushBack [_x#0, _x#1];
    } forEach _tags;
};

if (!isNil "_fields") then {
    {
        (_extSend select 3) pushBack [_x#0, _x#1];
    } forEach _fields;
};

// add to queue
(RangerMetrics_messageQueue getOrDefault [_bucket, [], true]) pushBack _extSend;

true
