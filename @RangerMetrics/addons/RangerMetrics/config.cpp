class CfgPatches {
	class RangerMetrics {
		units[] = {};
		weapons[] = {};
		requiredVersion = 2.10;
		requiredAddons[] = {};
		author[] = {"EagleTrooper","Gary","IndigoFox"};
		authorUrl = "http://example.com";
	};
};

class CfgFunctions {
	class RangerMetrics_callback {
		class functions {
			file = "\RangerMetrics\functions\callbackHandlers";
			class callbackHandler {};
			class loadSettings {};
		};
	};
	class RangerMetrics_event {
		class functions {
			file = "\RangerMetrics\functions\capture\EHOnly";
			class ace_unconscious {};
			class EntityKilled {};
			class Explosion {};
			class FiredMan {};
			class HandleChatMessage {};
			class MarkerCreated {};
			class MarkerDeleted {};
			class MarkerUpdated {};
			class milsim_serverEfficiency {};
		};
	};
	class RangerMetrics_cDefinitions {
		class functions {
			file = "\RangerMetrics\functions\captureDefinitions";
			class server_poll {};
			class server_missionEH {};
			class client_poll {};
			// class clientEvent {};
			class server_CBA {};
			class unit_handlers {};
		};
	};
	class RangerMetrics_capture {
		// these names represent measurement names send to InfluxDB - snake case
		class functions {
			file = "\RangerMetrics\functions\capture";
			class entity_count {};
			class mission_config_file {};
			class player_identity {};
			class player_performance {};
			class player_status {};
			class running_mission {};
			class running_scripts {};
			class server_performance {};
			class server_time {};
			class unit_inventory {};
			class unit_state {};
			class view_distance {};
			class weather {};
		};
	};
	class RangerMetrics {
		class core {
			file = "\RangerMetrics\functions\core";
			class postInit { postInit = 1; };
			class captureLoop {};
			class log {};
			class queue {};
			class send {};
			class sendClientPoll {};
			class startServerPoll {};
			class classHandlers {};
			class initCapture {};
		};
		class helpers {
			file = "\RangerMetrics\functions\helpers";
			class toLineProtocol {};
			class encodeJSON {};
			class stringReplace {};
			class unixTimestamp {};
		};
	};
};
