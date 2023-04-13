if (!RangerMetrics_run) exitWith {};

params [[
	"_unit", objNull, [objNull]
]];

if (isNull _unit || !(isPlayer _unit)) exitWith {};

// Used in Dammaged EH, so add a 1s delay to prevent spamming
_checkDelay = 1;
_lastCheck = _unit getVariable [
	"RangerMetrics_lastUnitStateCheck",
	diag_tickTime
];
if (
	(_lastCheck + _checkDelay) > diag_tickTime
) exitWith {};
_unit setVariable ["RangerMetrics_lastUnitStateCheck", diag_tickTime];

// Get owner playerUID
private _unitUID = getPlayerUID _unit;
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
private _inVehicle = !isNull (objectParent _unit);
if (_inVehicle) then {
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
	["bool", "in_vehicle", _inVehicle],
	["string", "vehicle_role", _vehicleRole],
	["float", "speed_kmh", speed _unit]
];

// Traits
private _playerTraits = getAllUnitTraits _unit;
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