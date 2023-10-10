# IFX Metrics - Arma3 Server Performance

This addon is designed to capture data from Arma3 and send it to InfluxDB. The extension is written in Golang and uses a non-blocking Write API to send data to InfluxDB.

The data in Influx can be used to create dashboards in Grafana.

---

## Setup

### ifxmetrics.config.json

Copy the ifxmetrics.config.example.json as ifxmetrics.config.json and edit the values to match your environment.

### Custom CBA Events to Log Metrics

The `cbaEventHandlers` sectio0n of the JSON configuration is used to enable custom server-side event listeners. In this way, you can capture measurements from custom scripts and send it to InfluxDB.

> You can read more about the data format that InfluxDB uses [here](https://docs.influxdata.com/influxdb/v2/get-started/write/#line-protocol-elements).

In this implementation, the bucket and measurement are defined in the config file. A bucket is created if it doesn't exist when you first send data to it, so you don't need to create buckets manually. As a tradeoff for security's sake, **the ability to define new buckets to send data to is not exposed to the scripter**.

As a brief note, tags are indexed while fields are not. This means that categorization generally happens at the tag level, and every field you submit will be categorized by each tag you provide with that send.

In the below example, the `milsimServerEfficiency` event handler will send data to `server_performance` (bucket) -> `milsim_server_efficiency` (measurement). The fields durationMs and vehicleCount will be sent as fields -- each can be easily filtered by the tags provided.

```json
// configuration file
// ...
  "cbaEventHandlers": {
    "milsimServerEfficiency": {
      "eventName": "milsimServerEfficiency",
      "description": "EVENTHANDLER. Tracks the efficiency of the server.",
      "enabled": true,
      "bucket": "server_performance",
      "measurement": "milsim_server_efficiency"
    }
  }
  // ...
```

```sqf
// your custom SQF script
fnc_getServerEfficiency = {
  private _startTime = diag_tickTime;

  // make and delete 99 vehicles
  for "_i" from 0 to 99 do {
    _vehicle = createVehicle ["B_Heli_Transport_01_F", findEmptyPosition [[0,0,0], 100, 10], [], 0, "FLY"];
    deleteVehicle _vehicle;
  };

  // get the time it took to make and delete 99 vehicles
  private _endTime = diag_tickTime;
  private _timeTaken = _endTime - _startTime;

  // send the data to InfluxDB
  ["milsimServerEfficiency", [
      [ // tags in hash format. must be string values!
          ["missionPhase", "init"],
          ["missionName", "My Mission"],
          ["missionType", "COOP"],
          ["serverName", "My Server"]
      ],
      [ // fields in hash format. can be any type
          ["durationMs", _timeTaken],
          ["vehicleCount", 99]
      ]
  ]] call CBA_fnc_serverEvent;
};
```

---

### InfluxDB

InfluxDB is a time series database. It is used to store data points with a timestamp.

To set up a basic Docker instance with data persisted in your terminal's current working directory, run the following command:

```bash
docker run -d -p 8086:8086 -v $PWD/influxdb/data:/var/lib/influxdb2 -v $PWD/influxdb/config:/etc/influxdb2 -e DOCKER_INFLUXDB_INIT_MODE=setup -e DOCKER_INFLUXDB_INIT_USERNAME=myuser -e DOCKER_INFLUXDB_INIT_PASSWORD=dfaow3ho9i7funa0w3nv -e DOCKER_INFLUXDB_INIT_ORG=ifx-metrics -e DOCKER_INFLUXDB_INIT_BUCKET=test-bucket -e DOCKER_INFLUXDB_INIT_RETENTION=1w -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=f0982q3ahfu8yawbo27w8fb986ba90b0wb2f influxdb:latest
```

This will create a new InfluxDB instance with the following credentials:
| Username | Password |
| --- | --- |
| myuser | dfaow3ho9i7funa0w3nv |

The database will be created with the following settings:
| Organization | Bucket | Retention |
| --- | --- | --- |
| ifx-metrics | test-bucket | 1 week |

The admin token, which is used with the InfluxDB API and CLI for administration, is:
| Token |
| --- |
| f0982q3ahfu8yawbo27w8fb986ba90b0wb2f |

Your InfluxDB instance will be available at <http://localhost:8086>.

### Grafana

Grafana is a dashboarding tool. It is used to display the data from InfluxDB. A sample dashboard is provided as a starting point.

---

## BUILDING

Set an environment variable in your terminal with the desired extension build version. It defaults to "DEVELOPMENT".

```powershell
# powershell
$IFXMETRICS_BUILD_VER = "2.0.0-$(Get-Date -Format 'yyyyMMdd')-$(git rev-parse --short HEAD)"
```

```bash
# bash
export IFXMETRICS_BUILD_VER="2.0.0-$(date -u '+%Y%m%d')-$(git rev-parse --short HEAD)"
```

### EXTENSION: COMPILING FOR WINDOWS

Run this from the project root.

```powershell
docker pull x1unix/go-mingw:1.20

# Compile x64 Windows DLL
docker run --rm -it -v ${PWD}:/go/work -w /go/work -e GOARCH=amd64 -e CGO_ENABLED=1 x1unix/go-mingw:1.20  go build -o ./ifxmetrics_x64.dll -buildmode=c-shared -ldflags "-w -s -X main.EXTENSION_VERSION=`"$IFXMETRICS_BUILD_VER`"" ./extension/cmd

# Compile x86 Windows DLL
docker run --rm -it -v ${PWD}:/go/work -w /go/work -e GOARCH=386 -e CGO_ENABLED=1 x1unix/go-mingw:1.20 go build -o ./ifxmetrics.dll -buildmode=c-shared -ldflags "-w -s -X main.EXTENSION_VERSION=`"$IFXMETRICS_BUILD_VER`"" ./extension/cmd

# Compile x64 Windows EXE
docker run --rm -it -v ${PWD}:/go/work -w /go/work -e GOARCH=amd64 -e CGO_ENABLED=1 x1unix/go-mingw:1.20 go build -o ./ifxmetrics_x64.exe -ldflags "-w -s -X main.EXTENSION_VERSION=`"$IFXMETRICS_BUILD_VER`"" ./extension/cmd
```

### EXTENSION: COMPILING FOR LINUX

Run this from the project root.

```powershell
docker build -t indifox926/build-a3go:linux-so -f ./build/Dockerfile.build .

# Compile x64 Linux .so
docker run --rm -it -v ${PWD}:/app -e GOOS=linux -e GOARCH=amd64 -e CGO_ENABLED=1 indifox926/build-a3go:linux-so go build -o ./ifxmetrics_x64.so -linkshared -ldflags "-w -s -X main.EXTENSION_VERSION=${IFXMETRICS_BUILD_VER}" ./extension/cmd

# Compile x86 Linux .so
docker run --rm -it -v ${PWD}:/app -e GOOS=linux -e GOARCH=386 -e CGO_ENABLED=1 indifox926/build-a3go:linux-so go build -o ./ifxmetrics.so -linkshared -ldflags "-w -s -X main.EXTENSION_VERSION=${IFXMETRICS_BUILD_VER}" ./extension/cmd
```

### ADDON: COMPILE USING HEMTT

Download the [HEMTT binary](https://github.com/BrettMayson/HEMTT/releases/latest) and place it in the project root. The configuration inside will be read by the HEMTT exe and defines the build process.

```powershell
./hemtt.exe release
```
