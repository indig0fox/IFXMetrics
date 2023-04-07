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
		class Common {
			file = "\RangerMetrics\functions";
			class postInit { postInit = 1;};
			class gather {};
			class queue {};
			class send {};
			class checkResults {};
			class log {};
		};
	};
};
