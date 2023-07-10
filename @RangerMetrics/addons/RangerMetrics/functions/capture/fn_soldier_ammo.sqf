if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "soldierAmmo";

// run for each side
{
	private _side = _x;
	private _allHash = createHashMap;

	// run function and increment hash for each player
	// the hash will wind up containing all mags and ammo count present for each soldier on this side
	{
		[_x, _allHash] call RangerMetrics_fnc_getMagsAmmo;
	} forEach (allUnits select {side _x == _side && alive _x && !isNull _x});

	{
		private _class = _x;
		_y params ["_displayName", "_magType", "_ammoCount"];

		[
			_settings getVariable "bucket",
			_settings getVariable "measurement",
			[ // tags
				["string", "class", _class],
				["string", "display_name", _displayName],
				["string", "mag_type", _magType],
				["string", "side", str _side]
			],
			[ // fields
				["int" ,"ammo_count", round(_ammoCount)]
			],
			["profile", "server", "world"] // context
		] call RangerMetrics_fnc_send;
	} forEach _allHash;

	// diag_log text format["RangerMetrics: %1 side complete, mags ammo: %2", _side, _allHash];
} forEach [west, east, independent, civilian];