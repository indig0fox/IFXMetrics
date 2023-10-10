#include "script_component.hpp"

if (!isServer) exitWith {};

if (typeName _this != "ARRAY") exitWith {
    diag_log format ["[%1]: Invalid log params: %2", GVARMAIN(logPrefix), _this];
};

params [
    ["_level", "INFO", [""]],
    ["_text", "", [""]]
];

if (
    _level == "DEBUG" && 
    !GVARMAIN(debug)
) exitWith {};

if (_text isEqualTo "") exitWith {};

diag_log formatText [
    "[%1] %2: %3",
    GVARMAIN(logPrefix),
    _level,
    _text
];

