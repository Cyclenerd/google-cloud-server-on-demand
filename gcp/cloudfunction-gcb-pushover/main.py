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
# This Google Cloud Function reads Cloud Build status messages
# from Pub/Sub logsink and sends a notification to Pushover
# if the status is 'ERROR' or 'TIMEOUT'.
#

import os
import base64
import json
import requests


def pushover(data: dict, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
        event (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """

    pushover_user_key = os.getenv('PUSHOVER_USER_KEY')
    pushover_api_token = os.getenv('PUSHOVER_API_TOKEN')

    console_url = 'https://console.cloud.google.com/cloud-build/builds'

    # Pub/Sub message
    pubsub_data = base64.b64decode(data["data"]).decode("utf-8")
    print(f"Data: {pubsub_data}")

    # Decode JSON
    pubsub_json = json.loads(pubsub_data)
    pubsub_text_payload = pubsub_json["textPayload"]
    print(f"Text Payload: {pubsub_text_payload}")
    pubsub_build_id = pubsub_json["resource"]["labels"]["build_id"]
    print(f"Build ID: {pubsub_build_id}")
    pubsub_project_id = pubsub_json["resource"]["labels"]["project_id"]
    print(f"Project: {pubsub_project_id}")
    pubsub_timestamp = pubsub_json["timestamp"]
    print(f"Timestamp: {pubsub_timestamp}")

    # Send notification
    # https://pushover.net/api
    post = {
        'user': pushover_user_key,
        'token': pushover_api_token,
        'title': f'GCB {pubsub_text_payload}',
        'message': f'Build ID:\n{pubsub_build_id}',
        'url': f'{console_url}?project={pubsub_project_id}',
        'url_title': pubsub_project_id
    }
    # https://requests.readthedocs.io/
    result = requests.post(
        "https://api.pushover.net/1/messages.json",
        json=post,
    )
    print(f"Result: {result}")
    return
