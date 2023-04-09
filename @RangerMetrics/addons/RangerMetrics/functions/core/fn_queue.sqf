params [
    ["_bucket", "default", [""]],
    "_measurement",
    ["_tags", [], [[], nil]],
    ["_fields", [], [[], nil]]
];


// format[
//     "profile=%1,world=%2,%3",
//     profileName,
//     toLower worldName,
//     (_tags apply {format['%1=%2', _x#0, _x#1]}) joinString ","
// ],

_tags pushback ["string", "profileName", profileName];
_tags pushBack ["string", "connectedServer", RangerMetrics_serverProfileName];



private _extSend = format [
    "%1,%2 %3 %4",
    _measurement, // metric name
    (_tags apply {_x call RangerMetrics_fnc_toLineProtocol}) joinString ",",
    (_fields apply {_x call RangerMetrics_fnc_toLineProtocol}) joinString ",",
    call RangerMetrics_fnc_unixTimestamp
];

// add to queue
(RangerMetrics_messageQueue getOrDefault [_bucket, [], true]) pushBack _extSend;

true
