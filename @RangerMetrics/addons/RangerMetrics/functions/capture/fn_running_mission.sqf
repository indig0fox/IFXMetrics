if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings getVariable "runningMission";

[
	_settings getVariable "bucket",
	_settings getVariable "measurement",
    nil, // tags
    [ // fields
        ["string","briefing_name", briefingName],
        ["string","mission_name", missionName],
        ["string","mission_name_source", missionNameSource],
        [
            "string",
            "on_load_name", 
            getMissionConfigValue ["onLoadName", ""]
        ],
        ["string","author", getMissionConfigValue ["author", ""]],
        ["string","server_name",serverName],
        ["int", "playable_slots_west", playableSlotsNumber west],
        ["int", "playable_slots_east", playableSlotsNumber east],
        ["int", "playable_slots_guer", playableSlotsNumber independent],
        ["int", "playable_slots_civ", playableSlotsNumber civilian],
        ["int", "playable_slots_logic", playableSlotsNumber sideLogic]

    ],
    ["profile", "server", "world"] // context
] call RangerMetrics_fnc_send;
