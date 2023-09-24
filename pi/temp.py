#!/usr/bin/env python

# Copyright 2023 Nils Knieling
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from google.cloud import pubsub_v1
from gpiozero import CPUTemperature
import google
import json
import os
import sys

# GOOGLE_APPLICATION_CREDENTIALS
google_application_credentials = ""
try:
    google_application_credentials = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
except KeyError:
    sys.exit("[ERROR] Environment variable GOOGLE_APPLICATION_CREDENTIALS not set!")

if not google_application_credentials:
    sys.exit("[ERROR] Please check GOOGLE_APPLICATION_CREDENTIALS.")

# MY_PROJECT
project_id = ""
try:
    project_id = os.environ['MY_PROJECT']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_PROJECT not set!")

if not project_id:
    sys.exit("[ERROR] Please check MY_PROJECT.")

# MY_PUBSUB_TOPIC_CREATE
topic_id = ""
try:
    topic_id = os.environ['MY_PUBSUB_TOPIC_TEMP']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_PUBSUB_TOPIC_TEMP not set!")

if not topic_id:
    sys.exit("[ERROR] Please check MY_PUBSUB_TOPIC_TEMP.")

# Get CPU temperature
cpu = CPUTemperature()
temp = cpu.temperature
print(f"CPU: {temp} 'C")
data = {}
data["temp"] = temp

# Google Pub/Sub Client
publisher = ""
try:
    publisher = pubsub_v1.PublisherClient()
except google.auth.exceptions.DefaultCredentialsError:
    sys.exit("[ERROR] Could not determine credentials.")
except Exception:
    sys.exit("[ERROR] Unknown error in Pub/Sub client.")
# Publish message
try:
    topic_path = publisher.topic_path(project_id, topic_id)
    # Message body must be a bytestring
    json_object = json.dumps(data)
    message = str(json_object).encode("utf-8")
    future = publisher.publish(topic_path, message)
    publish = future.result(timeout=60)
    print(f"Published message ID: {publish}")
except Exception:
    sys.exit("[ERROR] Cannot publish message!")
