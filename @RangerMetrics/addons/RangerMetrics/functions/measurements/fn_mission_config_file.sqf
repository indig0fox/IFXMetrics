// get basic config properties
private _properties = [
	["mission_info", [
		"author",
		"onLoadName",
		"onLoadMission",
		"loadScreen",
		// "header",
		"gameType",
		"minPlayers",
		"maxPlayers",
		"onLoadIntro",
		"onLoadMissionTime",
		"onLoadIntroTime",
		"briefingName",
		"overviewPicture",
		"overviewText",
		"overviewTextLocked"
	]],
	["respawn", [
		"respawn",
		"respawnButton",
		"respawnDelay",
		"respawnVehicleDelay",
		"respawnDialog",
		"respawnOnStart",
		"respawnTemplates",
		"respawnTemplatesWest",
		"respawnTemplatesEast",
		"respawnTemplatesGuer",
		"respawnTemplatesCiv",
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
	["player_ui", [
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
	["corpse_and_wreck", [
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
	["mission_settings", [
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
// recursively walk through missionConfigFile and get all properties into a single hashmap
// iterate through list of categories with desired property names
// if the property exists in the extracted missionConfigFile property hash, save it with the category into _propertyValues
{
	private _category = _x#0;
	private _values = _x#1;
	{
		private _property = _x;
		private _value = (missionConfigFile >> _property) call BIS_fnc_getCfgData;
		// hint str [_category, _property, _value];
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


// Take the generated hashmap of custom-categorized configuration properties and queue them for metrics
{
	private _measurementCategory = _x;
	private _fields = _y;
	private _fieldsWithType = [];

	// InfluxDB lookup hash
	_types = createHashMapFromArray [
		["STRING", "string"],
		["ARRAY", "string"],
		["SCALAR", "float"],
		["BOOL", "bool"]
	];

	// Preprocess the fields to clean the raw data
	{
		private _fieldName = _x;
		private _fieldValue = _y;
		private _fieldType = _types get (typeName _fieldValue);
		// turn ARRAY into string since Influx can't take them
		if (typeName _fieldValue == "ARRAY") then {
			_fieldValue = _fieldValue joinString "|";
		};
		// convert 0 or 1 (from config) to BOOL
		if (typeName _fieldValue == "SCALAR" && _fieldValue in [0, 1]) then {
			_fieldType = "bool";
			if (_fieldValue == 0) then {
				_fieldValue = "false";
			} else {
				_fieldValue = "true";
			};
		};
		_fieldsWithType pushBack [_fieldType, _fieldName, _fieldValue];
	} forEach _fields;

	// finally, send the data
	[
		"config_state",
		"mission_config_file",
		[
			["category", _measurementCategory]
		],
		_fieldsWithType
	] call RangerMetrics_fnc_queue;
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