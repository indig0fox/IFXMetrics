#include "script_component.hpp"

private _hashesOut = [];

private _allUnits = allUnits;
private _allDeadMen = allDeadMen;
private _allGroups = allGroups;
private _vehicles = vehicles;
private _allPlayers = call BIS_fnc_listPlayers;
{
	private _thisSide = _x;
	private _thisSideStr = _thisSide call BIS_fnc_sideNameUnlocalized;
	// Number of remote units
	_hashesOut pushBack ([
		["bucket", "server_performance"],
		["measurement", "entities_remote"],
		["tags", GVARMAIN(standardTags)],
		["fields", [
			["units_alive", {
				side _x isEqualTo _thisSide &&
				not (local _x)
			} count _allUnits],
			["units_dead", {
				side _x isEqualTo _thisSide &&
				not (local _x)
			} count _allDeadMen],
			["groups_total", {
				side _x isEqualTo _thisSide &&
				not (local _x)
			} count _allGroups],
			["vehicles_total", {
				side _x isEqualTo _thisSide &&
				not (local _x) &&
				!(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles],
			["vehicles_weaponholder", {
				side _x isEqualTo _thisSide &&
				not (local _x) &&
				(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles]
		]]
	]);

	// Number of local units
	_hashesOut pushBack ([
		["bucket", "server_performance"],
		["measurement", "entities_local"],
		["tags", GVARMAIN(standardTags)],
		["fields", [
			["units_alive", {
				side _x isEqualTo _thisSide &&
				local _x
			} count _allUnits],
			["units_dead", {
				side _x isEqualTo _thisSide &&
				local _x
			} count _allDeadMen],
			["groups_total", {
				side _x isEqualTo _thisSide &&
				local _x
			} count _allGroups],
			["vehicles_total", {
				side _x isEqualTo _thisSide &&
				local _x &&
				!(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles],
			["vehicles_weaponholder", {
				side _x isEqualTo _thisSide &&
				local _x &&
				(_x isKindOf "WeaponHolderSimulated")
			} count _vehicles]
		]]
	]);


	// Number of global units - only track on server
	if (isServer) then {
		_hashesOut pushBack ([
			["bucket", "server_performance"],
			["measurement", "entities_global"],
			["tags", GVARMAIN(standardTags)],
			["fields", [
				["units_alive", {
					side _x isEqualTo _thisSide
				} count _allUnits],
				["units_dead", {
					side _x isEqualTo _thisSide
				} count _allDeadMen],
				["groups_total", {
					side _x isEqualTo _thisSide
				} count _allGroups],
				["vehicles_total", {
					side _x isEqualTo _thisSide &&
					!(_x isKindOf "WeaponHolderSimulated")
				} count _vehicles],
				["vehicles_weaponholder", {
					side _x isEqualTo _thisSide &&
					(_x isKindOf "WeaponHolderSimulated")
				} count _vehicles],
				["players_alive", {
					side _x isEqualTo _thisSide &&
					alive _x
				} count _allPlayers],
				["players_dead", {
					side _x isEqualTo _thisSide &&
					!alive _x
				} count _allPlayers]
			]]
		]);
	};
} forEach [east, west, independent, civilian];

if (isServer) then {
	_hashesOut pushBack ([
		["bucket", "server_performance"],
		["measurement", "player_count"],
		["tags", GVARMAIN(standardTags)],
		["fields", [
			["players_connected", {
				private _info = getUserInfo (getPlayerId _x);
				if (!isNil "_info" && {count _info >= 6}) then {
					_info select 7
				} else {false}
			} count _allPlayers]
		]]
	]);
};

_hashesOut;