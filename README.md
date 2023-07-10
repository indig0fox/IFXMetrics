# RangerMetrics - Arma3 InfluxDB Metrics

This addon is designed to capture data from Arma3 and send it to InfluxDB. The extension is written in Golang and uses a non-blocking Write API to send data to InfluxDB.

The data in Influx can be used to create dashboards in Grafana.

---

## Setup

### Settings.json

Configure the options in settings.json.

### InfluxDB

InfluxDB is a time series database. It is used to store data points with a timestamp.

#### Required Buckets

- mission_data
- player_performance
- server_performance
- server_events
- soldier_ammo

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

To reload everything while in a game, run `"RangerMetrics" callExtension "initExtension";` in Global Exec. This will disconnect any database connections and reset state. Running it Global Exec will cause any client with the addon to run it, which includes Headless Clients.

When the extension is finished, it will notify Arma via a callback. The addon will then __automatically__ reinitialize the extension, to include fetching the new settings, tearing down existing captures, and re-setting up captures with the new settings.
