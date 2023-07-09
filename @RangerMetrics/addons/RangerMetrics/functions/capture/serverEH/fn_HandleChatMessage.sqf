if (!RangerMetrics_run) exitWith {};

params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType"];

// if (!_isPlayerMessage) exitWith {};

private _fields = [
	["int", "channel", _channel],
	["int", "owner", _owner],
	["string", "from", _from],
	["string", "text", _text],
	// ["object", "person", _person],
	["string", "name", _name],
	["string", "strID", _strID],
	["bool", "forcedDisplay", _forcedDisplay],
	["bool", "isPlayerMessage", _isPlayerMessage],
	["int", "sentenceType", _sentenceType],
	["int", "chatMessageType", _chatMessageType toFixed 0]
];

// we need special processing to ensure the object is valid and we have a playerUid. Line protocol doesn't support empty string
private "_playerUID";

if (parseNumber _strID > 1) then {
	_playerUID = (getUserInfo _strID)#2;
} else {
	_playerUID = "";
};

if (_playerUID isNotEqualTo "") then {
	_fields pushBack ["string", "playerUID", _playerUid];
};

[
	"server_events",
	"HandleChatMessage",
	nil,
	_fields,
	["server"]
] call RangerMetrics_fnc_send;