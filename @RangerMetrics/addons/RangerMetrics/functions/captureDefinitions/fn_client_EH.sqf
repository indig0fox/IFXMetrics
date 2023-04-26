if (!isServer) exitWith {};


// remoteExec to all machines with JIP -- will trigger when local
{
	if (!hasInterface) exitWith {};

	RangerMetrics_event_fnc_broadcastAceDamageSource = {
		params ["_unit"];
		private _aceLastDamage = _unit getVariable "ace_medical_lastDamageSource";
		if (!isNil "_aceLastDamage") then {
			_unit setVariable ["ace_medical_lastDamageSource", _aceLastDamage, 2];
		};
	};

	player addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		[_unit] call RangerMetrics_event_fnc_broadcastAceDamageSource;
	}];

	player addEventHandler ["Respawn", {
		params ["_unit", "_corpse"];
		_unit addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[_unit] call RangerMetrics_event_fnc_broadcastAceDamageSource;
		}];
	}];

	addMissionEventHandler ["HandleChatMessage", {
		params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType"];
		if !(missionNamespace getVariable ["RangerMetrics_run", false]) exitWith {};
		if (_owner == clientOwner && parseNumber _strID > 1) then {
			_this remoteExecCall ["RangerMetrics_event_fnc_HandleChatMessage", 2];
		};
		false;
	}];
} remoteExec ["call", 0, true];