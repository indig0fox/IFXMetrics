if (!RangerMetrics_run) exitWith {};

params ["_unit"];
if (isNull _unit || !(isPlayer _unit)) exitWith {};

// Get owner playerUID
private _unitUID = getPlayerUID _unitUID;
if (_unitUID isEqualTo "") exitWith {};

// Medical info
private _isUnconscious = false;
private _isInCardiacArrest = false;
if (RangerMetrics_aceMedicalPresent) then {
	_isUnconscious = _unit getVariable ["ace_medical_isUnconscious", false];
	_isInCardiacArrest = _unit getVariable ["ace_medical_isInCardiacArrest", false];
} else {
	_isUnconscious = (lifeState _unit) isEqualTo "INCAPACITATED"; 
};

// Vehicle info
if (!isNull (objectParent _unit)) then {
	_crew = fullCrew (objectParent _unit);
	_pos = _crew find {(_x select 0) isEqualTo _unit};
	_vehicleRole = toLower _crew select _pos select 1;
} else {
	_vehicleRole = "";
};

// Declare fields
private _fields = [
	["float", "health", 1 - (damage _unit)],
	["bool", "is_unconscious", _isUnconscious],
	["bool", "is_cardiac_arrest", _isInCardiacArrest],
	["bool", "is_captive", captive _unit],
	["bool", "in_vehicle", !isNull (objectParent _unit)],
	["string", "vehicle_role", _vehicleRole],
	["float", "speed_kmh", speed _unit]
];

// Role description
private _roleDescription = roleDescription _unit;
if (_roleDescription isNotEqualTo "") then {
	_fields pushBack ["string", "roleDescription", _roleDescription];
};

// Traits
private _playerTraits = getAllUnitTraits player;
{
	private _valueType = typeNAME (_x select 1);
	switch (_valueType) do {
		case "BOOL": {
			_fields pushBack ["bool", (_x select 0), (_x select 1)];
		};
		case "SCALAR": {
			_fields pushBack ["float", (_x select 0), (_x select 1)];
		};
		case "STRING": {
			_fields pushBack ["string", (_x select 0), (_x select 1)];
		};
	};
} forEach _playerTraits;


[
	"player_state",
	"unit_status",
	[
		["string", "playerUID", _unitUID]
	],
	_fields,
	["server"]
] call RangerMetrics_fnc_queue;