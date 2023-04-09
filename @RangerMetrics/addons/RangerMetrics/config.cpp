class CfgPatches {
	class RangerMetrics {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
		author[] = {"EagleTrooper","Gary","IndigoFox"};
		authorUrl = "http://example.com";
	};
};

class CfgFunctions {
	class RangerMetrics {
		class core {
			file = "\RangerMetrics\functions\core";
			class postInit { postInit = 1;};
			class captureLoop {};
			class log {};
			class queue {};
			class send {};
		};
		class eventHandlers {
			file = "\RangerMetrics\functions\eventHandlers";
			class addHandlers {};
			class callbackHandler {};
		};
		class helpers {
			file = "\RangerMetrics\functions\helpers";
			class toLineProtocol {};
			class encodeJSON {};
			class stringReplace {};
			class unixTimestamp {};
		};
		class measurements {
			file = "\RangerMetrics\functions\measurements";
			class chat_message {};
			class entities_global {};
			class entities_local {};
			class mission_config_file {};
			class player_identity {};
			class player_performance {};
			class player_status {};
			class running_mission {};
			class running_scripts {};
			class server_performance {};
			class server_time {};
		};
	};
};
