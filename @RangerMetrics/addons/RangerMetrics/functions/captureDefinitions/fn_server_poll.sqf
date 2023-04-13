[
	[
		1, // interval
		[ // functions to run
			[
				["server", "hc"],
				RangerMetrics_capture_fnc_server_performance
			]
		]
	],
	[
		3,
		[
			[
				["server", "hc"],
				RangerMetrics_capture_fnc_running_scripts
			],
			[
				["server", "hc"],
				RangerMetrics_capture_fnc_player_performance
			]
		]
	],
	[
		15,
		[
			[
				["server", "hc"],
				RangerMetrics_capture_fnc_server_time
			],
			[
				["hc"],
				RangerMetrics_capture_fnc_entity_count
			]
		]
	],
	[
		120,
		[
			[
				["server"],
				{
					{
						[_x] call RangerMetrics_capture_fnc_unit_inventory;
					} count (call BIS_fnc_listPlayers);
				}
			]
		]
	],
	[
		300,
		[
			[
				["server"],
				RangerMetrics_capture_fnc_weather
			],
			[
				["server"],
				RangerMetrics_capture_fnc_view_distance
			],
			[
				["server"],
				RangerMetrics_capture_fnc_running_mission
			]
		]
	]
]