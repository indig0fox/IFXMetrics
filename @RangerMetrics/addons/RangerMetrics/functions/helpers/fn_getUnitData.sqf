params [[
	"_unit", objNull, [objNull]
]];

if (isNull _unit) exitWith {};

private _playerID = getPlayerID _unit;
private _userInfo = (getUserInfo _playerID);
_userInfo call RangerMetrics_capture_fnc_player_identity;
_userInfo call RangerMetrics_capture_fnc_player_status;
[_unit] call RangerMetrics_capture_fnc_unit_state;
[_unit] call RangerMetrics_capture_fnc_unit_inventory;