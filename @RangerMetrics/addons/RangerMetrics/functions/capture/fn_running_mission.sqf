if (!RangerMetrics_run) exitWith {};

private _settings = RangerMetrics_recordingSettings get "runningMission";

[
	_settings get "bucket",
	_settings get "measurement",
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
        ["string","server_name",serverName]
    ],
    ["profile", "server", "world"] // context
] call RangerMetrics_fnc_queue;
