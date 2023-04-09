params ["_playerID", "_ownerId", "_playerUID", "_profileName", "_displayName", "_steamName", "_clientState", "_isHC", "_adminState", "_networkInfo", "_unit"];
// _networkInfo params ["_avgPing", "_avgBandwidth", "_desync"];

["player_state", "player_status", [], [
	["int", "clientStateNumber", _clientState],
	["int", "adminState", _adminState]
]] call RangerMetrics_fnc_queue;