params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType"];



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
	["int", "chatMessageType", _chatMessageType]
];

// we need special processing to ensure the object is valid and we have a playerUid. Line protocol doesn't support empty string
private "_playerUid";
if (isNil "_person") then {
	_playerUid = "";
} else {
	if !(objNull isEqualType _person) then {
		_playerUid = getPlayerUID _person;
	} else {
		_playerUid = "";
	};
};

if (_playerUid isNotEqualTo "") then {
	_fields pushBack ["string", "playerUid", _playerUid];
};

[
	"server_events",
	"HandleChatMessage",
	nil,
	_fields
] call RangerMetrics_fnc_queue;