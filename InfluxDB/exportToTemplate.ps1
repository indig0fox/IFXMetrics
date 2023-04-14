# Requires Influx CLI to be installed. Used to quickly generate a template of buckets to import to an instance for pre-setup.
# https://docs.influxdata.com/influxdb/v2.7/reference/cli/influx/export/
influx export all -f "bucketsTemplate.json" --filter=resourceKind=Bucket