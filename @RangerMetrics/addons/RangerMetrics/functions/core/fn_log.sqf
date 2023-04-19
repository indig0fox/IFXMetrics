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
    _text];

if(isServer) then {
    diag_log text _textFormatted;
    if(isMultiplayer) then {
        _playerIds = [];
        {
            _player = _x;
            _ownerId = owner _player;
            if(_ownerId > 0) then {
                if(getPlayerUID _player in ["76561198013533294"]) then {
                    _playerIds pushBack _ownerId;
                };
            };
        } foreach allPlayers;
        
        if(count _playerIds > 0) then {
            [_textFormatted] remoteExec ["diag_log", _playerIds];
        };
    };
};
