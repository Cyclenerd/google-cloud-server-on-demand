# Copyright 2023 Nils Knieling
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This Google Cloud function reads the Pub/Sub topic of the
# create build topic and writes the OS image to a custom monitoring metric.
#

import base64
import json
import os
import time

from google.cloud import monitoring_v3


def count(data: dict, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """

    # Project ID
    project_id = os.environ["MY_GOOGLE_CLOUD_PROJECT"]
    print(f"Project ID: {project_id}")

    # Region
    region = os.environ["MY_GOOGLE_CLOUD_REGION"]
    print(f"Region: {region}")

    # Pub/Sub message
    pubsub_data = base64.b64decode(data["data"]).decode("utf-8")
    print(f"Data: {pubsub_data}")

    # Decode JSON
    pubsub_json = json.loads(pubsub_data)
    image = pubsub_json["image"]
    print(f"OS image: {image}")

    # https://cloud.google.com/monitoring/custom-metrics/creating-metrics
    client = monitoring_v3.MetricServiceClient()
    series = monitoring_v3.TimeSeries()
    # https://cloud.google.com/monitoring/custom-metrics#identifier
    series.metric.type = "custom.googleapis.com/compute/os/images"
    # https://cloud.google.com/monitoring/api/resources#tag_generic_node
    series.resource.type = "global"
    series.resource.labels["project_id"] = project_id
    series.metric.labels["image"] = image

    now = time.time()
    seconds = int(now)
    nanos = int((now - seconds) * 10**9)
    interval = monitoring_v3.TimeInterval(
        {"end_time": {"seconds": seconds, "nanos": nanos}}
    )
    point = monitoring_v3.Point({
        "interval": interval,
        "value": {"double_value": 1.0}
    })
    series.points = [point]

    project_name = f"projects/{project_id}"
    client.create_time_series(name=project_name, time_series=[series])
