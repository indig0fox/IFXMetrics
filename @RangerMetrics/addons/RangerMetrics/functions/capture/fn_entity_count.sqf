if (!RangerMetrics_run) exitWith {};

private _allUnits = allUnits;
private _allDeadMen = allDeadMen;
private _allGroups = allGroups;
private _vehicles = vehicles;
private _allPlayers = call BIS_fnc_listPlayers;
{
	private _thisSide = _x;
	private _thisSideStr = _thisSide call BIS_fnc_sideNameUnlocalized;
	// Number of remote units
	["server_state", "entities_remote", [
		["string", "side", _thisSideStr]
	], [
		["int", "units_alive", {
			side _x isEqualTo _thisSide &&
			not (local _x)
		} count _allUnits],
		["int", "units_dead", {
			side _x isEqualTo _thisSide &&
			not (local _x)
		} count _allDeadMen],
		["int", "groups_total", {
			side _x isEqualTo _thisSide &&
			not (local _x)
		} count _allGroups],
		["int", "vehicles_total", {
			side _x isEqualTo _thisSide &&
			not (local _x) &&
			!(_x isKindOf "WeaponHolderSimulated")
		} count _vehicles],
		["int", "vehicles_weaponholder", {
			side _x isEqualTo _thisSide &&
			not (local _x) &&
			(_x isKindOf "WeaponHolderSimulated")
		} count _vehicles]
	]] call RangerMetrics_fnc_queue;

	// Number of local units
	["server_state", "entities_local", [
		["string", "side", _thisSideStr]
	], [
		["int", "units_alive", {
			side _x isEqualTo _thisSide &&
			local _x
		} count _allUnits],
		["int", "units_dead", {
			side _x isEqualTo _thisSide &&
			local _x
		} count _allDeadMen],
		["int", "groups_total", {
			side _x isEqualTo _thisSide &&
			local _x
		} count _allGroups],
		["int", "vehicles_total", {
			side _x isEqualTo _thisSide &&
			local _x &&
			!(_x isKindOf "WeaponHolderSimulated")
		} count _vehicles],
		["int", "vehicles_weaponholder", {
			side _x isEqualTo _thisSide &&
			local _x &&
			(_x isKindOf "WeaponHolderSimulated")
		} count _vehicles]
	]] call RangerMetrics_fnc_queue;

	// Number of global units - only track on server
	if (isServer) then {
		["server_state", "entities_global", [
			["string", "side", _thisSideStr]
		], [
			["int", "units_alive", {
				side _x isEqualTo _thisSide
			} count _allUnits],
			["int", "units_dead", {
				side _x isEqualTo _thisSide
			} count _allDeadMen],
			["int", "groups_total", {
				side _x isEqualTo _thisSide
			} count _allGroups],
			["int", "vehicles_total", {
				side _x isEqualTo _thisSide &&
				!(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles],
			["int", "vehicles_weaponholder", {
				side _x isEqualTo _thisSide &&
				(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles],
			["int", "players_alive", {
				side _x isEqualTo _thisSide &&
				alive _x
			} count _allPlayers],
			["int", "players_dead", {
				side _x isEqualTo _thisSide &&
				!alive _x
			} count _allPlayers]
		]] call RangerMetrics_fnc_queue;
	};

} forEach [east, west, independent, civilian];