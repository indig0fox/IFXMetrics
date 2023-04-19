params [
    ["_bucket", "default", [""]],
    "_measurement",
    ["_tags", [], [[], nil]],
    ["_fields", [], [[], nil]],
    ["_tagContext", ["profile", "server"], [[]]]
];


// format[
//     "profile=%1,world=%2,%3",
//     profileName,
//     toLower worldName,
//     (_tags apply {format['%1=%2', _x#0, _x#1]}) joinString ","
// ],

if (_tagContext find "profile" > -1) then {
    _tags pushBack ["string", "profileName", profileName];
};
if (_tagContext find "world" > -1) then {
    _tags pushBack ["string", "world", toLower worldName];
};
if (_tagContext find "server" > -1) then {
    private _serverProfile = missionNamespace getVariable [
            "RangerMetrics_serverProfileName",
            ""
    ];
    if (_serverProfile isNotEqualTo "") then {
        _tags pushBack [
            "string",
            "connectedServer",
            _serverProfile
        ];
    };
};

private _outTags = _tags apply {
    [_x, "tag"] call RangerMetrics_fnc_toLineProtocol
} select {!isNil "_x"};
// having no tags is OK

_outTags = _outTags joinString ",";


private _outFields = _fields apply {
    [_x, "field"] call RangerMetrics_fnc_toLineProtocol
} select {!isNil "_x"};
// having no fields will cause an error
if (count _outFields isEqualTo 0) exitWith {};

_outFields = _outFields joinString ",";


private _extSend = format [
    "%1,%2 %3 %4",
    _measurement, // metric name
    _outTags,
    _outFields,
    call RangerMetrics_fnc_unixTimestamp
];

// add to queue
(RangerMetrics_messageQueue getOrDefault [_bucket, [], true]) pushBack _extSend;

true
