if (!RangerMetrics_run) exitWith {};

params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {false};
if (!isPlayer _unit) exitWith {};

// do not check more than once every 15 seconds
_checkDelay = 15;
_lastCheck = _unit getVariable [
	"RangerMetrics_lastInventoryCheck",
	0
];
if (
	(_lastCheck + _checkDelay) > diag_tickTime
) exitWith {false};
_unit setVariable ["RangerMetrics_lastInventoryCheck", diag_tickTime];

private _lastLoadout = _unit getVariable "RangerMetrics_unitLoadout";
if (isNil "_lastLoadout") then {
	_lastLoadout = [];
};

private _uniqueUnitItems = uniqueUnitItems [_unit, 2, 2, 2, 2, true];  
// if (_lastLoadout isEqualTo _uniqueUnitItems) exitWith {false}; 
// _unit setVariable ["RangerMetrics_unitLoadout", _uniqueUnitItems];  
  
private _uniqueUnitItems = _uniqueUnitItems toArray false;  
_classItemCounts = [];
{
	_x params ["_item", "_count"]; 
	if (_item isEqualTo "") exitWith {};
	_classItemCounts pushBack ["int", _item, _count];
} forEach _uniqueUnitItems;
  
_playerUID = getPlayerUID _unit;  
_unitId = _unit getVariable ["RangerMetrics_Id", -1]; 
if (_unitId isEqualTo -1) exitWith {false}; 
 
 
// this section uses uniqueUnitItems to get a list of all items and their counts 
 
[ 
	"player_state", 
	"unit_loadout", 
	[ 
		["string", "playerUID", _playerUID], 
		["string", "format", "className"]
	], 
	_classItemCounts,
	["server"] 
] call RangerMetrics_fnc_queue; 
 
// prep displayName by fetching from configs 
_displayItemCounts = [];
{
	_x params ["_valueType", "_item", "_count"]; 

	// from CBA_fnc_getItemConfig, author: commy2
	private "_itemConfig"; 
	{
		private _config = configFile >> _x >> _item;

		if (isClass _config) exitWith {
			_itemConfig = _config;
		};
	} forEach ["CfgWeapons", "CfgMagazines", "CfgGlasses"];

	if (isNil "_itemConfig") then {
		private _config = configFile >> "CfgVehicles" >> _item;

		if (getNumber (_config >> "isBackpack") isEqualTo 1) then {
			_itemConfig = _config;
		};
	};

	_itemDisplayName = getText(_itemConfig >> "displayName");
	_displayItemCounts pushBack ["int", _itemDisplayName, _count];
} forEach _classItemCounts;

 
[ 
	"player_state", 
	"unit_loadout", 
	[ 
		["string", "playerUID", _playerUID],
		["string", "unitId", str _unitId],
		["string", "format", "displayName"] 
	], 
	_displayItemCounts, 
	["server"] 
] call RangerMetrics_fnc_queue; 

true; 



// get current loadout
// ! this section breaks everything down individually, see above for uniqueUnitItems implementation
// private _primaryWeapon = primaryWeapon _unit;
// (primaryWeaponItems _unit) params [
// 	"_primaryWeaponSilencer",
// 	"_primaryWeaponLaser",
// 	"_primaryWeaponOptics",
// 	"_primaryWeaponBipod"
// ];
// _primaryWeapon = [
// 	["string", "weapon", _primaryWeapon],
// 	["string", "silencer", _primaryWeaponSilencer],
// 	["string", "laser", _primaryWeaponLaser],
// 	["string", "optic", _primaryWeaponOptics],
// 	["string", "bipod", _primaryWeaponBipod]
// ];

// private _secondaryWeapon = secondaryWeapon _unit;
// (secondaryWeaponItems _unit) params [
// 	"_secondaryWeaponSilencer",
// 	"_secondaryWeaponLaser",
// 	"_secondaryWeaponOptics",
// 	"_secondaryWeaponBipod"
// ];
// _secondaryWeapon = [
// 	["string", "weapon", _secondaryWeapon],
// 	["string", "silencer", _secondaryWeaponSilencer],
// 	["string", "laser", _secondaryWeaponLaser],
// 	["string", "optic", _secondaryWeaponOptics],
// 	["string", "bipod", _secondaryWeaponBipod]
// ];

// private _handgun = handgunWeapon _unit;
// (handgunItems _unit) params [
// 	"_handgunSilencer",
// 	"_handgunLaser",
// 	"_handgunOptics",
// 	"_handgunBipod"
// ];
// _handgun = [
// 	["string", "weapon", _handgun],
// 	["string", "silencer", _handgunSilencer],
// 	["string", "laser", _handgunLaser],
// 	["string", "optic", _handgunOptics],
// 	["string", "bipod", _handgunBipod]
// ];

// private _magazinesFields = [];
// private _magazines = (magazines _unit) call BIS_fnc_consolidateArray;
// _magazines = _magazines apply {
// 	_x params ["_magazine", "_count"];
	// _magazinesFields pushBack ["int", _magazine, _count];
	// _magazinesFields pushBack ["int", getText(configFile >> "CfgMagazines" >> _magazine >> "displayName"), _count];
// };

// private _itemsFields = [];
// private _items = (items _unit) call BIS_fnc_consolidateArray;
// _items = _items apply {
// 	_x params ["_item", "_count"];
	// _itemsFields pushBack ["int", _item, _count];
	// _itemsFields pushBack ["int", getText(configFile >> "CfgWeapons" >> _item >> "displayName"), _count];
// };

// private _slotItems = [
// 	["string", "goggles", goggles _unit],
// 	["string", "gogglesClass", getText(configFile >> "CfgWeapons" >> (goggles _unit) >> "displayName")],
// 	["string", "headgear", headgear _unit],
// 	["string", "headgearClass", getText(configFile >> "CfgWeapons" >> (headgear _unit) >> "displayName")],
// 	["string", "binocular", binocular _unit],
// 	["string", "binocularClass", getText(configFile >> "CfgWeapons" >> (binocular _unit) >> "displayName")],
// 	["string", "uniform", uniform _unit],
// 	["string", "uniformClass", getText(configFile >> "CfgWeapons" >> (uniform _unit) >> "displayName")],
// 	["string", "vest", vest _unit],
// 	["string", "vestClass", getText(configFile >> "CfgWeapons" >> (vest _unit) >> "displayName")],
// 	["string", "backpack", backpack _unit],
// 	["string", "backpackClass", getText(configFile >> "CfgWeapons" >> (backpack _unit) >> "displayName")]
// ];


// send loadout data
// {
// 	[
// 		"player_state",
// 		"unit_loadout",
// 		[
// 			["string", "playerUID", _playerUID]
// 		],
// 		_x,
// 		["server"]
// 	] call RangerMetrics_fnc_queue;
// } forEach [
// 	_primaryWeapon,
// 	_secondaryWeapon,
// 	_handgun,
// 	_magazinesFields,
// 	_itemsFields,
// 	_slotItems
// ];


// true;