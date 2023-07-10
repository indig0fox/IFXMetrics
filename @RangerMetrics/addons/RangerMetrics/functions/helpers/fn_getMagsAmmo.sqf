params [
	["_unit", objNull, [objNull]],
	["_hash", createHashMap, [createHashMap]]
];

_magazines = magazinesAmmoFull _unit;

{
	_x params [
		"_class",
		"_ammoCount",
		"_isLoaded",
		"_magTypeBit"
	];

	private _magType = switch (_magTypeBit) do {
		case -1: {""};
		case 0: {"grenade"};
		case 1: {"primaryMagazine"};
		case 2: {"handgunMagazine"};
		case 4: {"secondaryMagainze"};
		case 4096: {"binocularMagazine"};
		case 65536: {"vehicleMagazine"};
	};

	_config = (configFile >> "CfgMagazines" >> _class);
	_dname = getText(_config >> "displayName");
	private _existing = _hash getOrDefault [_class, [_dname, _magType, 0]];
	_hash set [_class, [
		_dname,
		_magType,
		(_existing#2) + _ammoCount
	]];
} forEach _magazines;



