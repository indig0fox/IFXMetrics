
// function adapted from YAINA by MartinCo at http://yaina.eu

params ["_args"];
_args params [["_cba",false,[true]]];

if(missionNamespace getVariable ["RangerMetrics_run",false]) then {
    private _startTime = diag_tickTime;

    // Mission Name
  //  private _missionName = missionName;
  //  ["missionName", _missionName] call RangerMetrics_fnc_send;

    // World Name
   // private _worldName = worldName;
   // ["worldName", _worldName] call RangerMetrics_fnc_send;

    // Server Name
   // private _serverName = serverName;
   // ["serverName", _serverName] call RangerMetrics_fnc_send;

    // Number of local units
    ["count.units", { local _x } count allUnits] call RangerMetrics_fnc_send;
    ["count.groups", { local _x } count allGroups] call RangerMetrics_fnc_send;
    ["count.vehicles", { local _x} count vehicles] call RangerMetrics_fnc_send;
    
    // Server Stats
    ["stats.fps", round diag_fps] call RangerMetrics_fnc_send;
    ["stats.fpsMin", round diag_fpsMin] call RangerMetrics_fnc_send;
    ["stats.uptime", round diag_tickTime] call RangerMetrics_fnc_send;
    ["stats.missionTime", round time] call RangerMetrics_fnc_send;
    
    // Scripts
    private _activeScripts = diag_activeScripts;
    ["scripts.spawn", _activeScripts select 0] call RangerMetrics_fnc_send;
    ["scripts.execVM", _activeScripts select 1] call RangerMetrics_fnc_send;
    ["scripts.exec", _activeScripts select 2] call RangerMetrics_fnc_send;
    ["scripts.execFSM", _activeScripts select 3] call RangerMetrics_fnc_send;
    
    private _pfhCount = if(_cba) then {count CBA_common_perFrameHandlerArray} else {0};
    ["scripts.pfh", _pfhCount] call RangerMetrics_fnc_send;
    
    // Globals if server
    if (isServer) then {
        // Number of local units
        ["count.units", count allUnits, true] call RangerMetrics_fnc_send;
        ["count.groups", count allGroups, true] call RangerMetrics_fnc_send;
        ["count.vehicles", count vehicles, true] call RangerMetrics_fnc_send;
        ["count.players", count allPlayers, true] call RangerMetrics_fnc_send;
    };

    





    private _headlessClients = entities "HeadlessClient_F";
    {
        {
            private _stats_fps = round diag_fps;
            ["stats.HCfps", _stats_fps] remoteExec ["RangerMetrics_fnc_send", 2];
            
        } remoteExecCall ["bis_fnc_call", owner _x];
    } foreach _headlessClients;




/** WORKING HEADLESS CODE COMMENTED OUT TO TRY SOMETHING DIFFERNT

    // Headless Clients FPS
    // Thanks to CPL.Brostrom.A
    private _headlessClients = entities "HeadlessClient_F";
    {
        {
            private _stats_fps = round diag_fps;
            ["stats.HCfps", _stats_fps] remoteExec ["RangerMetrics_fnc_send", 2];
        } remoteExecCall ["bis_fnc_call", owner _x];
    } foreach _headlessClients;
    

*/



    // log the runtime and switch off debug so it doesn't flood the log
    if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
        [format ["Run time: %1", diag_tickTime - _startTime], "DEBUG"] call RangerMetrics_fnc_log;
        missionNamespace setVariable ["RangerMetrics_debug",false];
    };
};
