import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS
import threading
from pyproj import Transformer
from datetime import datetime
import json
import os
from .threading_utils import call_slow_function, has_call_finished, get_call_value

settings = None


host = settings["influxdb"]["host"]
token = settings["influxdb"]["token"]
org = settings["influxdb"]["org"]
bucket = settings["influxdb"]["bucket"]
refreshRateMs = settings["arma3"]["refreshRateMs"]

transformer = Transformer.from_crs("epsg:3857", "epsg:4326")

DBCLIENT = influxdb_client.InfluxDBClient(
    url=host, token=token, org=org, enable_gzip=True
)
WRITE_API = DBCLIENT.write_api(write_options=SYNCHRONOUS)


def get_dir():
    # get current dir
    return [
        os.path.dirname(os.path.realpath(__file__)) + "\\" + os.path.basename(__file__)
    ]


def load_settings():
    # import settings from settings.json
    global settings
    with open("settings.json", "r") as f:
        settings = json.load(f)
    # get path to arma3 directory
    global arma3_path


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


def log_to_file(data):
    # threaded, write backup to file
    with open("influxdb_data.log", "a") as f:
        f.write(f"{data}\n")
    return True


def write_data(data):
    # thread the write to influxdb
    # t = threading.Thread(target=write_points_async, args=(data,), daemon=True)
    # t.start()
    thread_id = call_slow_function(write_points_async, data)
    return [thread_id]


def write_points_async(data):
    processed = []
    timestamp = f" {int(datetime.now().timestamp() * 1e9)}"

    process_log = open("influxdb_process.log", "a")

    # process_log.write(f"{datetime.now()}: Processing {len(data)} data points\n")
    # process_log.write(f"{datetime.now()}: {data[0]}\n")

    for point in data:
        measurement = point[0]
        tag_set = point[1]
        field_set = point[2]
        if len(point) > 3:
            position = point[3]

        tag_dict = dict(tag_set)
        field_dict = dict(field_set)

        point_dict = {
            "measurement": measurement,
            "tags": tag_dict,
            "fields": field_dict,
        }

        if position is not None:

            # convert position to lat/lon
            lat, lon = transformer.transform(
                position[0],
                position[1],
            )
            point_dict["fields"]["lat"] = lat
            point_dict["fields"]["lon"] = lon
            point_dict["fields"]["alt"] = position[2]

        processed.append(point_dict)

    # process_log.write(f"{datetime.now()}: Writing {len(processed)} data points\n")
    # process_log.write(f"{datetime.now()}: {json.dumps(processed, indent=2)}\n")

    try:
        result = WRITE_API.write(bucket, org, processed)
        process_log.write(f"{datetime.now()}: Success\n")
    except Exception as e:
        # write to file
        with open("influxdb_error.log", "a") as f:
            f.write(f"{datetime.now()}: {e}\n")

    # free up memory
    del processed
    del transformer
    del timestamp
    del process_log

    return ("OK", 200)


has_call_finished  # noqa imported functions
get_call_value  # noqa imported functions
