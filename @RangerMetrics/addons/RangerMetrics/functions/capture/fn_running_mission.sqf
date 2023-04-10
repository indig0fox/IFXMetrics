// Mission name
[
    "server_state", // bucket to store the data
    "running_mission", // measurement classifier inside of bucket
    nil, // tags
    [ // fields
        [
            "string",
            "onLoadName", 
            getMissionConfigValue ["onLoadName", ""]
        ],
        ["string","briefingName", briefingName],
        ["string","missionName", missionName],
        ["string","missionNameSource", missionNameSource]
    ]
] call RangerMetrics_fnc_queue;
