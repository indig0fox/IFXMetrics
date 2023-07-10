[
	["OnUserConnected", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		private _tags = [];
		if (!isNil "_userInfo") then {
			_tags pushBack ["string", "playerUID", _userInfo#2];
		};
		["server_events", "OnUserConnected",
		_tags, [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) OnUserConnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserDisconnected", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		private _tags = [];
		if (!isNil "_userInfo") then {
			_tags pushBack ["string", "playerUID", _userInfo#2];
		};
		["server_events", "OnUserDisconnected",
			_tags, [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) OnUserDisconnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["PlayerConnected", {
		params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
		private _userInfo = (getUserInfo _idstr);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		// [_entity] call RangerMetrics_capture_fnc_unit_inventory;
		["server_events", "PlayerConnected", [
			["string", "playerUID", _uid]
		], [
			["string", "id", _id toFixed 0],
			["string", "uid", _uid],
			["string", "name", _name],
			["bool", "jip", _jip],
			["int", "owner", _owner],
			["string", "idstr", _idstr]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) PlayerConnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["HandleDisconnect", {
		params ["_unit", "_id", "_uid", "_name"];
		private _userInfo = (getUserInfo (_id toFixed 0));
		["server_events", "HandleDisconnect", [
			["string", "playerUID", _uid]
		], [
			["string", "id", _id toFixed 0],
			["string", "uid", _uid],
			["string", "name", _name]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) HandleDisconnect fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
		false;
	}],
	["OnUserClientStateChanged", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		["server_events", "OnUserClientStateChanged", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) OnUserClientStateChanged fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserAdminStateChanged", {
		params ["_networkId", "_loggedIn", "_votedIn"];
		private _userInfo = (getUserInfo _networkId);
		if (isNil "_userInfo") exitWith {};
		["server_events", "OnUserAdminStateChanged", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["bool", "loggedIn", _loggedIn],
			["bool", "votedIn", _votedIn]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) OnUserAdminStateChanged fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserKicked", {
		params ["_networkId", "_kickTypeNumber", "_kickType", "_kickReason", "_kickMessageIncReason"];
		private _userInfo = (getUserInfo _networkId);
		if (isNil "_userInfo") exitWith {};
		["server_events", "OnUserKicked", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "kickTypeNumber", _kickTypeNumber],
			["string", "kickType", _kickType],
			["string", "kickReason", _kickReason],
			["string", "kickMessageIncReason", _kickMessageIncReason]
		]] call RangerMetrics_fnc_send;
		[format ["(EventHandler) OnUserKicked fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["HandleChatMessage", {
		_this call RangerMetrics_event_fnc_HandleChatMessage;
		// don't interfaere with the chat message
		false;
	}],
	["MPEnded", {
		private ["_winner", "_reason"];
		_winner = "Unknown";
		_reason = "Mission Complete";
		["server_events", "MPEnded", nil, [
			["string", "winner", _winner],
			["string", "reason", _reason]
		]] call RangerMetrics_fnc_send;
		call RangerMetrics_capture_fnc_running_mission;
		[format ["(EventHandler) MPEnded fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["EntityCreated", {
		params ["_entity"];
		if (
			!(_entity isKindOf "AllVehicles")
		) exitWith {};

		call RangerMetrics_capture_fnc_entity_count;
		[format["(EventHandler) EntityCreated fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["EntityKilled", {
		params ["_entity"];
		if (
			!(_entity isKindOf "AllVehicles")
		) exitWith {};
		call RangerMetrics_capture_fnc_entity_count;

		[format["(EventHandler) EntityKilled fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["EntityRespawned", {
		params ["_newEntity", "_oldEntity"];
		call RangerMetrics_capture_fnc_entity_count;

		[format["(EventHandler) EntityRespawned fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["GroupCreated", {
		params ["_group"];
		call RangerMetrics_capture_fnc_entity_count;
		[format["(EventHandler) GroupCreated fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["GroupDeleted", {
		params ["_group"];
		call RangerMetrics_capture_fnc_entity_count;
		[format["(EventHandler) GroupDeleted fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}]
];