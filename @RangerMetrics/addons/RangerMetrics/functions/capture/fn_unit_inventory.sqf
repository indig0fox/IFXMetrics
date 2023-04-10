params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};

private _lastLoadout = _unit getVariable "RangerMetrics_myLoadout";
if (isNil "_lastLoadout") then {
	_lastLoadout = [];
}; 

private _currentLoadout = [
	["string", "currentWeapon", currentWeapon _unit],
	["string", "uniform", uniform _unit],
	["string", "vest", vest _unit],
	["string", "backpack", backpack _unit],
	["string", "headgear", headgear _unit],
	["string", "goggles", goggles _unit],
	["string", "hmd", hmd _unit],
	["string", "primaryWeapon", primaryWeapon _unit],
	["string", "primaryWeaponMagazine", primaryWeaponMagazine _unit],
	["string", "secondaryWeapon", secondaryWeapon _unit],
	["string", "secondaryWeaponMagazine", secondaryWeaponMagazine _unit],
	["string", "handgunWeapon", handgunWeapon _unit],
	["string", "handgunMagazine", handgunMagazine _unit]
];

// exit if loadout hasn't changed
if (_lastLoadout isEqualTo _currentLoadout) exitWith {};

// continue if loadout has changed

// store loadout data locally
_unit setVariable ["RangerMetrics_myLoadout", _currentLoadout];

_playerUID = getPlayerUID _unit;


// send loadout data
[
	"player_state",
	"unit_loadout",
	[
		["string", "playerUID", _playerUID]
	],
	_currentLoadout,
	["server"]
] call RangerMetrics_fnc_queue;