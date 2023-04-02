
// function adapted from YAINA by MartinCo at http://yaina.eu

if !(isServer || !hasInterface) exitWith {};
_cba = (isClass(configFile >> "CfgPatches" >> "cba_main"));

[format ["Instance name: %1", profileName]] call RangerMetrics_fnc_log;
[format ["CBA detected: %1", _cba]] call RangerMetrics_fnc_log;
["Initializing v1.1"] call RangerMetrics_fnc_log;

RangerMetrics_run = true;

if(_cba) then { // CBA is running, use PFH
    [RangerMetrics_fnc_run, 10, [_cba]] call CBA_fnc_addPerFrameHandler;
} else { // CBA isn't running, use sleep
    [_cba] spawn {
        params ["_cba"];
        while{true} do {
            [[_cba]] call RangerMetrics_fnc_run; // nested to match CBA PFH signature
            sleep 10;
        };
    };
};
