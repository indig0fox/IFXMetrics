# RangerMetrics - Arma3 InfluxDB Metrics

Ranger Metrics is used to submit information from the Arma3 Instance to the Influx Database. This uses the ArmaInflux Version complied to a DLL to communicate.

---

## Setup

### Settings.json

Configure the options in settings.json.

As of v0.0.2, metrics are captured on a recurring loop in the scheduled environment with a two second pause to allow time. Whether to use CBA Per Frame Handlers that run metric collection less often and in the unscheduled environment has yet to be decided on, as it does lead to longer intervals that are more difficult to graph precisely.

### InfluxDB

InfluxDB is a time series database. It is used to store data points with a timestamp.

#### Required Buckets

- mission_data
- player_data
- player_performance
- server_events
- server_performance

### Grafana

Grafana is a dashboarding tool. It is used to display the data from InfluxDB. Import the dashboard from the json file in the root of this addon and set up your datasources appropriately.

---

## Usage

### Ingame

#### Toggle Capture On/Off

Running the following commands in Server Exec will toggle the capture on or off for the server and any Headless Clients. Capture loops will still occur but will exit almost immediately.

Change the last parameter to false to ONLY target the server when run as Server Exec.

*This may not apply to raw Event Handler data which goes under `server_events`*

```sqf
// ON
missionNamespace setVariable ["RangerMetrics_run", true, true];

// OFF
missionNamespace setVariable ["RangerMetrics_run", false, true];
```

#### Reload Settings.json and recreate all capture loops

To reload everything while in a game, run `"RangerMetrics" callExtension "deinitExtension";` in Global Exec. This will disconnect any database connections and reset state. Running it Global Exec will cause any client with the addon to run it, which includes Headless Clients.

When the extension is finished, it will notify Arma via a callback. The addon will then __automatically__ run `"RangerMetrics" callExtension "initExtension";` to reinitialize the extension, to include fetching the new settings, tearing down existing captures, and re-setting up captures with the new settings.
