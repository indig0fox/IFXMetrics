// loadout data, captured clientside
if (isNull player) exitWith {};

params ["_handleName"];

private _lastLoadout = player getVariable "RangerMetrics_myLoadout";
if (isNil "_lastLoadout") then {
	_lastLoadout = [];
}; 

private _currentLoadout = [
	["string", "currentWeapon", currentWeapon player],
	["string", "uniform", uniform player],
	["string", "vest", vest player],
	["string", "backpack", backpack player],
	["string", "headgear", headgear player],
	["string", "goggles", goggles player],
	["string", "hmd", hmd player],
	["string", "primaryWeapon", primaryWeapon player],
	["string", "primaryWeaponMagazine", primaryWeaponMagazine player],
	["string", "secondaryWeapon", secondaryWeapon player],
	["string", "secondaryWeaponMagazine", secondaryWeaponMagazine player],
	["string", "handgunWeapon", handgunWeapon player],
	["string", "handgunMagazine", handgunMagazine player]
];

// exit if loadout hasn't changed
if (_lastLoadout isEqualTo _currentLoadout) exitWith {};

// continue if loadout has changed

// store loadout data locally
player setVariable ["RangerMetrics_myLoadout", _currentLoadout];

// send loadout data to server
[
	"player_state", // bucket to store the data
	"player_loadout", // measurement classifier inside of bucket
	[ // tags
		["string", "playerUID", getPlayerUID player]
	],
	_currentLoadout, // fields
	nil
] remoteExec ["RangerMetrics_fnc_queue", 2];
