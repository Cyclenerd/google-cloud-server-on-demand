# Copyright 2022-2023 Nils Knieling
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
# from Pub/Sub logsink and sends a notification to Discord
# if the status is 'ERROR' or 'TIMEOUT'.
#

import os
import re
import sys
import base64
import json
import requests


def discord(data: dict, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """

    # Discord Webhook URL
    url = os.getenv('DISCORD_WEBHOOK_URL')
    reqex = re.search(
        'discord(?:app)?\\.com\\/api\\/webhooks\\/\\d+/[^/?]+',
        url
    )
    if reqex:
        print("[OK] Discord webhook URL")
    else:
        sys.exit("[ERROR] Invalid Discord webhook URL!")

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
    if pubsub_text_payload in ['ERROR', 'TIMEOUT']:
        # Create webhook JSON
        # https://discord.com/developers/docs/resources/webhook#execute-webhook
        console_url = 'https://console.cloud.google.com/cloud-build/builds'
        data = {}
        data['embeds'] = []
        embed = {}
        embed['title'] = f'GCB {pubsub_text_payload}'
        embed['description'] = f'Build ID:\n{pubsub_build_id}'
        embed['url'] = (
            f'{console_url};'
            f'region=global/{pubsub_build_id}'
            f'?project={pubsub_project_id}'
        )
        embed['timestamp'] = f'{pubsub_timestamp}'
        embed['color'] = '16711680'
        embed['author'] = {}
        embed['author']['name'] = f'Project: {pubsub_project_id}'
        embed['author']['url'] = f'{console_url}?project={pubsub_project_id}'
        embed['footer'] = {}
        embed['footer']['text'] = 'Google Cloud Build'
        embed['footer']['icon_url'] = 'https://i.imgur.com/hO7DkUK.png'
        # Image source: https://github.com/GoogleCloudBuild
        data['embeds'].append(embed)
        result = requests.post(
            url,
            data=json.dumps(data),
            headers={"Content-Type": "application/json"}
        )
        print(f"Result: {result}")
        return result
