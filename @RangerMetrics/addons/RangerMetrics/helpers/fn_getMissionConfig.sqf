// get basic config properties
private _properties = [
	["settings_mission_info", [
		"author",
		"onLoadName",
		"onLoadMission",
		"loadScreen",
		"header",
		"onLoadIntro",
		"onLoadMissionTime",
		"onLoadIntroTime",
		"briefingName",
		"overviewPicture",
		"overviewText",
		"overviewTextLocked",
		"onBriefingGear",
		"onBriefingGroup",
		"onBriefingPlan"
	]],
	["settings_respawn", [
		"respawn",
		"respawnButton",
		"respawnDelay",
		"respawnVehicleDelay",
		"respawnDialog",
		"respawnOnStart",
		"respawnTemplates",
		"respawnWeapons",
		"respawnMagazines",
		"reviveMode",
		"reviveUnconsciousStateMode",
		"reviveRequiredTrait",
		"reviveRequiredItems",
		"reviveRequiredItemsFakConsumed",
		"reviveMedicSpeedMultiplier",
		"reviveDelay",
		"reviveForceRespawnDelay",
		"reviveBleedOutDelay",
		"enablePlayerAddRespawn"
	]],
	["settings_player_ui", [
			"overrideFeedback",
			"showHUD",
			"showCompass",
			"showGPS",
			"showGroupIndicator",
			"showMap",
			"showNotePad",
			"showPad",
			"showWatch",
			"showUAVFeed",
			"showSquadRadar"
	]],
	["settings_corpse_and_wreck", [
		"corpseManagerMode",
		"corpseLimit",
		"corpseRemovalMinTime",
		"corpseRemovalMaxTime",
		"wreckManagerMode",
		"wreckLimit",
		"wreckRemovalMinTime",
		"wreckRemovalMaxTime",
		"minPlayerDistance"
	]],
	["settings_mission_general", [
			"aiKills",
			"briefing",
			"debriefing",
			"disableChannels",
			"disabledAI",
			"disableRandomization",
			"enableDebugConsole",
			"enableItemsDropping",
			"enableTeamSwitch",
			"forceRotorLibSimulation",
			"joinUnassigned",
			"minScore",
			"avgScore",
			"maxScore",
			"onCheat",
			"onPauseScript",
			"saving",
			"scriptedPlayer",
			"skipLobby",
			"HostDoesNotSkipLobby",
			"missionGroup"
		]
	]
];

private _propertyValues = createHashMap;
{
	private _category = _x#0;
	private _values = _x#1;
	{
		private _property = _x;
		private _value = (missionConfigFile >> _property) call BIS_fnc_getCfgData;
		hint str [_category, _property, _value];
		if (!isNil "_value") then {
			if (typeName _value == "ARRAY") then {
				_value = _value joinString ",";
			};
			if (isNil {_propertyValues get _category}) then {
				_propertyValues set [_category, createHashMap];
			};
			_propertyValues get _category set [_property, _value];
		};
	} forEach _values;
} forEach _properties;


// Take the generated hashmap and queue metrics
{
	private _measurementCategory = _x;
	private _fields = _y;
	["config", _measurementCategory, nil, _fields, "int", 0] call RangerMetrics_fnc_queue;
} forEach _propertyValues;




// get all properties in missionConfigFile (recursive)
// private _nextCfgClasses = "true" configClasses (missionConfigFile);
// private _nextCfgProperties = configProperties [missionConfigFile];
// private _cfgProperties = createHashMap;
// while {count _nextCfgClasses > 0} do {
//     {
//         private _thisConfig = _x;
//         private _thisConfigClasses = "true" configClasses _thisConfig;
//         _thisCfgProperties = configProperties [_thisConfig, "!isClass _x"];
//         _saveHash = createHashMap;
//         {
//             _propertyCfg = _x;
//             _saveHash set [configName _propertyCfg, (_propertyCfg) call BIS_fnc_getCfgData];
//         } forEach _thisCfgProperties;
//         _hierarchy = (configHierarchy _thisConfig);
//         _hierarchy deleteAt 0;
//         _hierarchy = _hierarchy apply {configName _x};
//         _hierarchyStr = _hierarchy joinString ".";
//         _hierarchyStrParent = (_hierarchy select [0, count _hierarchy - 2]) joinString ".";
//         systemChat _hierarchyStrParent;

//         // if (_cfgProperties get _hierarchyStrParent == nil) then {
//         //     _cfgProperties set [_hierarchyStrParent, createHashMap];
//         // };
//         _cfgProperties set [_hierarchyStr, _saveHash];


//         // _cfgProperties set [_hierarchy, _saveHash];
//         _nextCfgClasses append _thisConfigClasses;

//     } forEach _nextCfgClasses;
//     _nextCfgClasses = _nextCfgClasses - _cfgClasses;
// };
// text ([_cfgProperties] call RangerMetrics_fnc_encodeJSON);





// iterate through _cfgProperties hashmap and queue metrics
// {

// } forEach _cfgProperties;