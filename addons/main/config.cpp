#include "script_component.hpp"

class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = 2.10;
		requiredAddons[] = {
			"cba_main",
			"cba_xeh",
			"cba_settings"
		};
		author[] = {"IndigoFox"};
		authorUrl = "https://github.com/indig0fox/IFXMetrics";
	};
};

class CfgFunctions {
	class ADDON {
		class functions {
			class postInit {
				file = QPATHTOF(DOUBLES(fnc,postInit).sqf);
				postInit = 1;
			};
			PATHTO_FNC(callbackHandler);
			PATHTO_FNC(captureLoop);
			PATHTO_FNC(log);
			PATHTO_FNC(onExtLoad);
		};
	};
};
