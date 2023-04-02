class CfgPatches {
	class RangerMetrics {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
		author[] = {"EagleTrooper and Gary"};
		authorUrl = "http://example.com";
	};
};

class CfgFunctions {
	class RangerMetrics {
		class Common {
			file = "\RangerMetrics\functions";
			class postInit { postInit = 1;};
			class log {};
			class send {};
			class run {};
		};
	};
};
