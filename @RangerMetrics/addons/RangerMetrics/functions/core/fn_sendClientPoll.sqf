// format [interval, [[handleName, code], [handleName, code], ...]]
[_this, {
	if !(hasInterface || isDedicated) exitWith {};
	params [
		["_interval", 5, [5]],
		["_pollItems", []]
	];
	{
		_x params [
			"_handleName",
			["_code", {}, [{}]]
		];

		private _runningCBA = (isClass(configFile >> "CfgPatches" >> "cba_main"));
		if (_runningCBA) then {
			localNamespace setVariable [
				_handleName,
				[_code, _interval, _handleName] call CBA_fnc_addPerFrameHandler
			];
		} else {
			localNamespace setVariable [
				_handleName,
				[_handleName, _interval] spawn {
					params [
						"_handleName",
						"_interval"
					];
					while {true} do {
						[_handleName] call _code;
						sleep _interval;
					};
				}
			];
		};
	} forEach _pollItems;
}] remoteExec ["call", [0, -2] select isDedicated, true];