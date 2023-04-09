// Mission name
[
    "server_state", // bucket to store the data
    "mission_name", // measurement classifier inside of bucket
    nil, // tags
    [ // fields
        [
            "string",
            "onLoadName", 
            [
                getMissionConfigValue ["onLoadName", ""],
                " ",
                "\ "
            ] call RangerMetrics_fnc_stringReplace
        ],
        ["string","briefingName", briefingName],
        ["string","missionName", missionName],
        ["string","missionNameSource", missionNameSource]
    ]
] call RangerMetrics_fnc_queue;
