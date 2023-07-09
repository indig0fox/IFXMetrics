freeExtension "RangerMetrics";
// sleep 0.5;
// "RangerMetrics" callExtension "loadSettings";
// "RangerMetrics" callExtension "version";
// "RangerMetrics" callExtension "connectToInflux";
// "RangerMetrics" callExtension "connectToTimescale";
// sleep 5;
// "RangerMetrics" callExtension "initTimescale";

// addMissionEventHandler ["ExtensionCallback", {
// 	params ["_extension", "_function", "_data"];
// 	if (
// 		_extension == "RangerMetrics" && _function isEqualTo "connectToTimescale"
// 	) then {
// 		diag_log format ["RangerMetrics: %1", _data];
// 	};
// }];
"RangerMetrics" callExtension "deinitExtension";
sleep 1;
"RangerMetrics" callExtension "initExtension";

sleep 20;
"RangerMetrics" callExtension "deinitExtension";
// freeExtension "RangerMetrics";
sleep 5;
exit;