addMissionEventHandler ["MPEnded", {

}];

addMissionEventHandler ["OnUserConnected", {
	params ["_networkId", "_clientStateNumber", "_clientState"];
	(getUserInfo _networkId) call RangerMetrics_fnc_player_identity;
	(getUserInfo _networkId) call RangerMetrics_fnc_player_status;
	["server_events", "UserConnected", nil, [
		["string", "networkId", _networkId],
		["int", "clientStateNumber", _clientStateNumber],
		["string", "clientState", _clientState]
	]] call RangerMetrics_fnc_queue;
}];
addMissionEventHandler ["OnUserDisconnected", {
	params ["_networkId", "_clientStateNumber", "_clientState"];
	(getUserInfo _networkId) call RangerMetrics_fnc_player_identity;
	(getUserInfo _networkId) call RangerMetrics_fnc_player_status;
	["server_events", "OnUserDisconnected", nil, [
		["string", "networkId", _networkId],
		["int", "clientStateNumber", _clientStateNumber],
		["string", "clientState", _clientState]
	]] call RangerMetrics_fnc_queue;
}];

addMissionEventHandler ["PlayerConnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
	(getUserInfo _idstr) call RangerMetrics_fnc_player_identity;
	(getUserInfo _idstr) call RangerMetrics_fnc_player_status;
	["server_events", "PlayerConnected", nil, [
		["int", "id", _id],
		["string", "uid", _uid],
		["string", "name", _name],
		["bool", "isJip", _jip],
		["int", "owner", _owner],
		["string", "idstr", _idstr]
	]] call RangerMetrics_fnc_queue;
}];
addMissionEventHandler ["PlayerDisconnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
	(getUserInfo _idstr) call RangerMetrics_fnc_player_identity;
	(getUserInfo _idstr) call RangerMetrics_fnc_player_status;
	["server_events", "PlayerDisconnected", nil, [
		["int", "id", _id],
		["string", "uid", _uid],
		["string", "name", _name],
		["bool", "isJip", _jip],
		["int", "owner", _owner],
		["string", "idstr", _idstr]
	]] call RangerMetrics_fnc_queue;
}];

addMissionEventHandler ["OnUserClientStateChanged", {
	params ["_networkId", "_clientStateNumber", "_clientState"];
	(getUserInfo _networkId) call RangerMetrics_fnc_player_status;
	["server_events", "OnUserClientStateChanged", nil, [
		["string", "networkId", _networkId],
		["int", "clientStateNumber", _clientStateNumber],
		["string", "clientState", _clientState]
	]] call RangerMetrics_fnc_queue;
}];
addMissionEventHandler ["OnUserAdminStateChanged", {
	params ["_networkId", "_loggedIn", "_votedIn"];
	(getUserInfo _networkId) call RangerMetrics_fnc_player_status;
	["server_events", "OnUserAdminStateChanged", nil, [
		["string", "networkId", _networkId],
		["bool", "loggedIn", _loggedIn],
		["bool", "votedIn", _votedIn]
	]] call RangerMetrics_fnc_queue;
}];

addMissionEventHandler ["HandleChatMessage", {
	_this call RangerMetrics_fnc_chat_message;
	// don't interfaere with the chat message
	false;
}];
