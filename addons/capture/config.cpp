#include "script_component.hpp"

class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = 2.10;
		requiredAddons[] = {"cba_main"};
		author[] = {"IndigoFox"};
		authorUrl = "https://github.com/indig0fox/IFXMetrics";
	};
};

class CfgFunctions {
	class ADDON {
		class functions {
			PATHTO_FNC(entity_count);
			PATHTO_FNC(player_performance);
			PATHTO_FNC(running_mission);
			PATHTO_FNC(running_scripts);
			PATHTO_FNC(server_performance);
			PATHTO_FNC(server_time);
			PATHTO_FNC(weather);
		};
	};
};
