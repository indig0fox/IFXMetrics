[
	["OnUserConnected", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "OnUserConnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) OnUserConnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserDisconnected", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "OnUserDisconnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) OnUserDisconnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["PlayerConnected", {
		params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		// [_entity] call RangerMetrics_capture_fnc_unit_inventory;
		["server_events", "PlayerConnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "id", _id toFixed 0],
			["string", "uid", _uid],
			["string", "name", _name],
			["bool", "jip", _jip],
			["int", "owner", _owner],
			["string", "idstr", _idstr]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) PlayerConnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["PlayerDisconnected", {
		params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "PlayerDisconnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "id", _id toFixed 0],
			["string", "uid", _uid],
			["string", "name", _name],
			["bool", "jip", _jip],
			["int", "owner", _owner],
			["string", "idstr", _idstr]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) PlayerDisconnected fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserClientStateChanged", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "OnUserClientStateChanged", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) OnUserClientStateChanged fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserAdminStateChanged", {
		params ["_networkId", "_loggedIn", "_votedIn"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "OnUserAdminStateChanged", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["bool", "loggedIn", _loggedIn],
			["bool", "votedIn", _votedIn]
		]] call RangerMetrics_fnc_queue;
		[format ["(EventHandler) OnUserAdminStateChanged fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["OnUserKicked", {
		params ["_networkId", "_kickTypeNumber", "_kickType", "_kickReason", "_kickMessageIncReason"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "OnUserKicked", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "kickTypeNumber", _kickTypeNumber],
			["string", "kickType", _kickType],
			["string", "kickReason", _kickReason],
			["string", "kickMessageIncReason", _kickMessageIncReason]
		]] call RangerMetrics_fnc_queue;
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
		]] call RangerMetrics_fnc_queue;
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
		_this call RangerMetrics_event_fnc_EntityKilled;
		call RangerMetrics_capture_fnc_entity_count;
		// [_entity] call RangerMetrics_capture_fnc_unit_inventory;
		// [_entity] call RangerMetrics_capture_fnc_unit_state;

		[format["(EventHandler) EntityKilled fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	}],
	["EntityRespawned", {
		params ["_newEntity", "_oldEntity"];
		call RangerMetrics_capture_fnc_entity_count;
		// [_entity] call RangerMetrics_capture_fnc_unit_inventory;
		// [_entity] call RangerMetrics_capture_fnc_unit_state;
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
	// ["MarkerCreated", {
	// 	params ["_marker", "_channelNumber", "_owner", "_local"];
	// 	if (markerType _marker isEqualTo "") exitWith {};
	// 	_this call RangerMetrics_event_fnc_MarkerCreated;
	// 	[format["(EventHandler) MarkerCreated fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	// }],
	// ["MarkerDeleted", {
	// 	params ["_marker", "_channelNumber", "_owner", "_local"];
	// 	if (markerType _marker isEqualTo "") exitWith {};
	// 	_this call RangerMetrics_event_fnc_MarkerDeleted;
	// 	[format["(EventHandler) MarkerDeleted fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	// }],
	// ["MarkerUpdated", {
	// 	params ["_marker", "_local"];
		// if (markerType _marker isEqualTo "") exitWith {};
	// 	_this call RangerMetrics_event_fnc_MarkerUpdated;
	// }],
	// ["Service", {
	// 	params ["_serviceVehicle", "_servicedVehicle", "_serviceType", "_needsService", "_autoSupply"];
	// 	[
	// 		"server_events",
	// 		"Service",
	// 		[
	// 			["string", "serviceVehicle", typeOf _serviceVehicle],
	// 			["string", "servicedVehicle", typeOf _servicedVehicle],
	// 			["int", "serviceType", _serviceType],
	// 			["bool", "needsService", _needsService],
	// 			["bool", "autoSupply", _autoSupply]
	// 		],
	// 		nil
	// 	] call RangerMetrics_fnc_queue;
	// 	[format["(EventHandler) Service fired: %1", _this], "DEBUG"] call RangerMetrics_fnc_log;
	// }]
]