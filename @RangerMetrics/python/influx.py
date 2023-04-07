import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS
import threading
from pyproj import Transformer
from datetime import datetime
import json
import os
from .threading_utils import (
    call_slow_function,
    has_call_finished,
    get_call_value,
    THREADS,
    THREAD_ID,
)

# get parent of parent directory (mod dir)
MOD_DIR = (
    os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    .lstrip("\\")
    .lstrip("?")
    .lstrip("\\")
)

SETTINGS_FILE = ""
SETTINGS = None

DBCLIENT = None
WRITE_API = None

PROCESS_LOG = MOD_DIR + "\\rangermetrics_process.log"
ERROR_LOG = MOD_DIR + "\\rangermetrics_error.log"
DATA_LOG = MOD_DIR + "\\rangermetrics_data.log"


# TRANSFORMER = Transformer.from_crs("epsg:3857", "epsg:4326")


def get_dir():
    # get current dir without leading or trailing slashes
    this_path = (
        os.path.dirname(os.path.realpath(__file__))
        .lstrip("\\")
        .lstrip("?")
        .lstrip("\\")
    )
    return [0, "Current directory", this_path, PROCESS_LOG]


def load_settings():
    # check if settings.json exists in MOD_DIR
    if not (os.path.isfile(os.path.join(MOD_DIR, "settings.json"))):
        return [1, "settings.json not found in mod directory", MOD_DIR]

    global SETTINGS_FILE
    SETTINGS_FILE = os.path.join(MOD_DIR, "settings.json")

    # import settings from settings.json
    global SETTINGS
    with open(SETTINGS_FILE, "r") as f:
        SETTINGS = json.load(f)

    settings_validation = [
        ["influxdb", "host"],
        ["influxdb", "token"],
        ["influxdb", "org"],
        ["influxdb", "defaultBucket"],
        ["arma3", "refreshRateMs"],
    ]
    for setting in settings_validation:
        if not (setting[0] in SETTINGS and setting[1] in SETTINGS[setting[0]]):
            return [1, f"Missing setting: {setting[0]} {setting[1]}"]

    # prep settings out to hashMap style list for A3
    # [[key, [subkey, subvalue], [subkey, subvalue]]]
    settings_out = []
    for key, value in SETTINGS.items():
        if isinstance(value, dict):
            this_values = []
            for subkey, subvalue in value.items():
                this_values.append([subkey, subvalue])
            settings_out.append([key, this_values])
        else:
            settings_out.append([key, value])
    return [0, "Settings loaded", settings_out]


def connect_to_influx():
    global DBCLIENT
    DBCLIENT = influxdb_client.InfluxDBClient(
        url=SETTINGS["influxdb"]["host"],
        token=SETTINGS["influxdb"]["token"],
        org=SETTINGS["influxdb"]["org"],
        enable_gzip=True,
    )
    if DBCLIENT is None:
        return [1, "Error connecting to InfluxDB"]
    global WRITE_API
    WRITE_API = DBCLIENT.write_api(write_options=SYNCHRONOUS)
    if WRITE_API is None:
        return [1, "Error connecting to InfluxDB"]
    return [0, "Connected to InfluxDB"]


def test_data(data):
    with open("influxdb_data.log", "a") as f:
        f.write(str(data) + "\n")
        f.write(f"{datetime.now()}: {data[2]}\n")
        # convert to dict from list of key, value pairs
        # format [[key, value], [key, value]] to {key: value, key: value}
        measurement, tag_set, field_set, position = data
        tag_dict = dict(tag_set)
        field_dict = dict(field_set)
        f.write(
            f"{datetime.now()}: {measurement}, {json.dumps(tag_dict, indent=2)}, {json.dumps(field_dict, indent=2)}, {position}\n"
        )

    # thread the write to influxdb
    return [data, dict(data[1])]


def log_process(line):
    # log the process to a file
    with open(PROCESS_LOG, "a+") as f:
        f.write(f"{datetime.now()}: {line}\n")
    return True


def log_error(line):
    # log errors to a file
    with open(ERROR_LOG, "a+") as f:
        f.write(f"{datetime.now()}: {line}\n")
    return True


def write_influx(data):
    # thread the write to influxdb
    thread_id = call_slow_function(write_influx_async, (data,))
    return [thread_id]


def write_influx_async(data):
    processed = []
    timestamp = f" {int(datetime.now().timestamp() * 1e9)}"
    # return [data]
    target_bucket = data[0] or SETTINGS["influxdb"]["defaultBucket"]
    log_process(f"Writing to bucket {target_bucket}")

    log_process(f"Processing {len(data)} data points")
    for point in data[1]:

        measurement = point[0]
        value_type = point[1]
        tag_dict = dict(point[2])
        field_dict = dict(point[3])

        if value_type == "int":
            field_dict["value"] = int(field_dict["value"])
        elif value_type == "float":
            field_dict["value"] = float(field_dict["value"])

        point_dict = {
            "measurement": measurement,
            "tags": tag_dict,
            "fields": field_dict,
        }

        processed.append(point_dict)

    log_process(f"Writing {len(processed)} data points")

    try:
        result = WRITE_API.write(target_bucket, SETTINGS["influxdb"]["org"], processed)
        if result is not None:
            log_process(f"Wrote {len(processed)} data points")
    except Exception as e:
        # write to file
        log_error(f"Error writing to influxdb: {e}")
        return [1, f"Error writing to influxdb: {e}"]

    success_count = len(processed)
    # free up memory
    del data
    del processed
    del timestamp

    return [0, f"Wrote {success_count} data points successfully"]


has_call_finished  # noqa imported functions
get_call_value  # noqa imported functions
