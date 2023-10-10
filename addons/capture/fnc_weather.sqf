#include "script_component.hpp"

[
	["bucket", "mission_data"],
	["measurement", "weather"],
	["tags", GVARMAIN(standardTags)],
	["fields", [
		["fog", fog],
		["overcast", overcast],
		["rain", rain],
		["humidity", humidity],
		["waves", waves],
		["windDir", windDir],
		["windStr", windStr],
		["gusts", gusts],
		["lightnings", lightnings],
		["moonIntensity", moonIntensity],
		["moonPhase", moonPhase date],
		["sunOrMoon", sunOrMoon]
	]]
];
