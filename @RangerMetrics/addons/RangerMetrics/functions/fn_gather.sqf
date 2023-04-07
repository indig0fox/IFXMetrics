
// function adapted from YAINA by MartinCo at http://yaina.eu

params [["_cba",false,[true]]];

if(missionNamespace getVariable ["RangerMetrics_run",false]) then {
    private _startTime = diag_tickTime;

    // Mission name
    ["server", "mission_name", [["source", "onLoadName"]], nil, "string", getMissionConfigValue ["onLoadName", ""]] call RangerMetrics_fnc_queue;
    ["server", "mission_name", [["source", "missionName"]], nil, "string", missionName] call RangerMetrics_fnc_queue;
    ["server", "mission_name", [["source", "missionNameSource"]], nil, "string", missionNameSource] call RangerMetrics_fnc_queue;
    ["server", "mission_name", [["source", "briefingName"]], nil, "string", briefingName] call RangerMetrics_fnc_queue;

    ["server", "server_uptime", nil, nil, "float", diag_tickTime toFixed 2] call RangerMetrics_fnc_queue;

    // Number of local units
    ["simulation", "entity_count", [["entity_type", "unit"], ["only_local", true]], nil, "int", { local _x } count allUnits] call RangerMetrics_fnc_queue;
    ["simulation", "entity_count", [["entity_type", "group"], ["only_local", true]], nil, "int", { local _x } count allGroups] call RangerMetrics_fnc_queue;
    ["simulation", "entity_count", [["entity_type", "vehicles"], ["only_local", true]], nil, "int", { local _x} count vehicles] call RangerMetrics_fnc_queue;
    
    // Server Stats
    ["simulation", "fps", [["metric", "avg"]], nil, "float", diag_fps toFixed 2] call RangerMetrics_fnc_queue;
    ["simulation", "fps", [["metric", "avg_min"]], nil, "float", diag_fpsMin toFixed 2] call RangerMetrics_fnc_queue;
    ["simulation", "mission_time", nil, nil, "float", time toFixed 2] call RangerMetrics_fnc_queue;
    
    // Scripts
    private _activeScripts = diag_activeScripts;
    ["simulation", "script_count", [["execution", "spawn"]], nil, "int", _activeScripts select 0] call RangerMetrics_fnc_queue;
    ["simulation", "script_count", [["execution", "execVM"]], nil, "int", _activeScripts select 1] call RangerMetrics_fnc_queue;
    ["simulation", "script_count", [["execution", "exec"]], nil, "int", _activeScripts select 2] call RangerMetrics_fnc_queue;
    ["simulation", "script_count", [["execution", "execFSM"]], nil, "int", _activeScripts select 3] call RangerMetrics_fnc_queue;
    
    private _pfhCount = if(_cba) then {count CBA_common_perFrameHandlerArray} else {0};
    ["simulation", "script_count", [["execution", "pfh"]], nil, "int", _pfhCount] call RangerMetrics_fnc_queue;
    
    // Globals if server
    if (isServer) then {
        // Number of global units
        ["simulation", "entity_count", [["entity_type", "unit"], ["only_local", false]], nil, "int", count allUnits] call RangerMetrics_fnc_queue;
        ["simulation", "entity_count", [["entity_type", "group"], ["only_local", false]], nil, "int", count allGroups] call RangerMetrics_fnc_queue;
        ["simulation", "entity_count", [["entity_type", "vehicle"], ["only_local", false]], nil, "int", count vehicles] call RangerMetrics_fnc_queue;
        ["simulation", "entity_count", [["entity_type", "player"], ["only_local", false]], nil, "int", count allPlayers] call RangerMetrics_fnc_queue;
    };


    private _headlessClients = entities "HeadlessClient_F";
    {
        {
            private _stats_fps = diag_fps toFixed 2;
            private _stats_fps_min = diag_fpsMin toFixed 2;
            ["simulation", "fps_hc", [["metric", "avg"]], nil, "float", _stats_fps] remoteExec ["RangerMetrics_fnc_queue", 2];
            ["simulation", "fps_hc", [["metric", "avg_min"]], nil, "float", _stats_fps_min] remoteExec ["RangerMetrics_fnc_queue", 2];
            
        } remoteExecCall ["bis_fnc_call", owner _x];
    } foreach _headlessClients;




/** WORKING HEADLESS CODE COMMENTED OUT TO TRY SOMETHING DIFFERNT

    // Headless Clients FPS
    // Thanks to CPL.Brostrom.A
    private _headlessClients = entities "HeadlessClient_F";
    {
        {
            private _stats_fps = round diag_fps;
            ["stats.HCfps", _stats_fps] remoteExec ["RangerMetrics_fnc_queue", 2];
        } remoteExecCall ["bis_fnc_call", owner _x];
    } foreach _headlessClients;
    

*/



    // log the runtime and switch off debug so it doesn't flood the log
    if(missionNamespace getVariable ["RangerMetrics_debug",false]) then {
        [format ["Run time: %1", diag_tickTime - _startTime], "DEBUG"] call RangerMetrics_fnc_log;
        // missionNamespace setVariable ["RangerMetrics_debug",false];
    };
};
