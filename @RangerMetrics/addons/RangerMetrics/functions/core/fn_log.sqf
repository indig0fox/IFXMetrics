if (!isServer) exitWith {};

params [["_text","Log text invalid"], ["_logType","DEBUG"]];

if (typeName _this != "ARRAY") exitWith {
    diag_log format ["RangerMetrics: Invalid log params: %1", _this];
};
if (typeName _text != "STRING") exitWith {
    diag_log format ["RangerMetrics: Invalid log text: %1", _this];
};
if (typeName _logType != "STRING") exitWith {
    diag_log format ["RangerMetrics: Invalid log type: %1", _this];
};

if (
    _logType == "DEBUG" && 
    !(missionNamespace getVariable ["RangerMetrics_debug", false])
) exitWith {};

private _textFormatted = format [
    "[%1] %2: %3",
    RangerMetrics_logPrefix,
    _logType,
    _text
];


diag_log text _textFormatted;
