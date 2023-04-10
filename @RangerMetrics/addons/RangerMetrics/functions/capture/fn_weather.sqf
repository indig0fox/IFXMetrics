if (!RangerMetrics_run) exitWith {};

[
	"server_state", // bucket to store the data
	"weather", // measurement classifier inside of bucket
	nil, // tags
	[ // fields
		["float", "fog", fog],
		["float", "overcast", overcast],
		["float", "rain", rain],
		["float", "humidity", humidity],
		["float", "waves", waves],
		["float", "windDir", windDir],
		["float", "windStr", windStr],
		["float", "gusts", gusts],
		["float", "lightnings", lightnings],
		["float", "moonIntensity", moonIntensity],
		["float", "moonPhase", moonPhase date],
		["float", "sunOrMoon", sunOrMoon]
	]
] call RangerMetrics_fnc_queue;
