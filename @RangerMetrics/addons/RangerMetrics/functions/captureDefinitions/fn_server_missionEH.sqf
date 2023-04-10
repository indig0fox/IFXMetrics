[
	["OnUserConnected", {
		params ["_networkId", "_clientStateNumber", "_clientState"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "UserConnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["string", "networkId", _networkId],
			["int", "clientStateNumber", _clientStateNumber],
			["string", "clientState", _clientState]
		]] call RangerMetrics_fnc_queue;
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
	}],
	["PlayerConnected", {
		params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "PlayerConnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["int", "id", _id],
			["string", "uid", _uid],
			["string", "name", _name],
			["bool", "jip", _jip],
			["int", "owner", _owner],
			["string", "idstr", _idstr]
		]] call RangerMetrics_fnc_queue;
	}],
	["PlayerDisconnected", {
		params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
		private _userInfo = (getUserInfo _networkId);
		_userInfo call RangerMetrics_capture_fnc_player_identity;
		_userInfo call RangerMetrics_capture_fnc_player_status;
		["server_events", "PlayerDisconnected", [
			["string", "playerUID", _userInfo#2]
		], [
			["int", "id", _id],
			["string", "uid", _uid],
			["string", "name", _name],
			["bool", "jip", _jip],
			["int", "owner", _owner],
			["string", "idstr", _idstr]
		]] call RangerMetrics_fnc_queue;
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
	}],
	["EntityCreated", {
		params ["_entity"];
		call RangerMetrics_capture_fnc_entity_count;
	}],
	["EntityKilled", {
		_this call RangerMetrics_event_fnc_EntityKilled;
	}],
	["GroupCreated", {
		params ["_group"];
		call RangerMetrics_capture_fnc_entity_count;
	}],
	["GroupDeleted", {
		params ["_group"];
		call RangerMetrics_capture_fnc_entity_count;
	}],
	["MarkerCreated", {
		params ["_marker", "_channelNumber", "_owner", "_local"];
		_this call RangerMetrics_event_fnc_MarkerCreated;
	}],
	["MarkerDeleted", {
		params ["_marker", "_channelNumber", "_owner", "_local"];
		_this call RangerMetrics_event_fnc_MarkerDeleted;
	}],
	["MarkerUpdated", {
		params ["_marker", "_channelNumber", "_owner", "_local"];
		_this call RangerMetrics_event_fnc_MarkerUpdated;
	}],
	["Service", {
		params ["_serviceVehicle", "_servicedVehicle", "_serviceType", "_needsService", "_autoSupply"];
		[
			"server_events",
			"Service",
			[
				["string", "serviceVehicle", typeOf _serviceVehicle],
				["string", "servicedVehicle", typeOf _servicedVehicle],
				["int", "serviceType", _serviceType],
				["bool", "needsService", _needsService],
				["bool", "autoSupply", _autoSupply]
			],
			nil
		] call RangerMetrics_fnc_queue;
	}]
]