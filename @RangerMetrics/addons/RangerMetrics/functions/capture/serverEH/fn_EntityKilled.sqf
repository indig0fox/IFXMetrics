if (!RangerMetrics_run) exitWith {};
params ["_killed", "_killer", "_instigator"];

if (!isPlayer _killed) exitWith {}; // only track player deaths

// check in case ACE is active and lastDamageSource has been broadcast via addLocalSoldierEH
_instigator = _unit getVariable [
	"ace_medical_lastDamageSource", 
	_instigator
];


if (isNull _instigator) then { _instigator = UAVControl vehicle _killer select 0 }; // UAV/UGV player operated road kill
if (isNull _instigator) then { _instigator = _killer }; // player driven vehicle road kill
if (isNull _instigator) then { _instigator = _killed };
// hint format ["Killed By %1", name _instigator];

if (!isPlayer _killed && !isPlayer _instigator) exitWith {}; // only track player kills

private _tags = [];
private _fields = [];

if (getPlayerUID _instigator != "") then {
	_tags pushBack ["string", "killerPlayerUID", getPlayerUID _instigator];
};
if (name _instigator != "") then {
	_fields pushBack ["string", "killerName", name _instigator];
};

if (getPlayerUID _killed != "") then {
	_tags pushBack ["string", "killedPlayerUID", getPlayerUID _killed];
};
if (name _killed != "") then {
	_fields pushBack ["string", "killedName", name _killed];
};

[
	"server_events",
	"EntityKilled",
	_tags,
	_fields,
	["server"]
] call RangerMetrics_fnc_send;
