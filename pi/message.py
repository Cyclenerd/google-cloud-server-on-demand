#!/usr/bin/env python

# Copyright 2022-2023 Nils Knieling
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

#
# Generate a test message for Pub/Sub and Cloud Build trigger
#

from google.cloud import pubsub_v1
import string
import crypt
import json
import random
import google
import sys
import os
import re

# GOOGLE_APPLICATION_CREDENTIALS
google_application_credentials = ""
try:
    google_application_credentials = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
except KeyError:
    sys.exit("[ERROR] Environment variable GOOGLE_APPLICATION_CREDENTIALS not set!")

if google_application_credentials:
    print(f"Google Credentials: {google_application_credentials}")
else:
    sys.exit("[ERROR] Please check GOOGLE_APPLICATION_CREDENTIALS.")

# MY_PROJECT
project_id = ""
try:
    project_id = os.environ['MY_PROJECT']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_PROJECT not set!")

if project_id:
    print(f"Google Project: {project_id}")
else:
    sys.exit("[ERROR] Please check MY_PROJECT.")

# MY_PUBSUB_TOPIC_CREATE
topic_id = ""
try:
    topic_id = os.environ['MY_PUBSUB_TOPIC_CREATE']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_PUBSUB_TOPIC_CREATE not set!")

if topic_id:
    print(f"Google Pub/Sub Topic: {topic_id}")
else:
    sys.exit("[ERROR] Please check MY_PUBSUB_TOPIC_CREATE.")

# MY_DNS_DOMAIN
dns_domain = ""
try:
    dns_domain = os.environ['MY_DNS_DOMAIN']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_DNS_DOMAIN not set!")

if dns_domain:
    pattern = r'\.$'
    dns_domain = re.sub(pattern, '', dns_domain)
    print(f"DNS Domain: {dns_domain}")
else:
    sys.exit("[ERROR] Please check MY_DNS_DOMAIN.")

# MY_EXPIRES
expires = ""
try:
    expires = os.environ['MY_EXPIRES']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_EXPIRES not set!")

# Set Google Cloud OS image
image = "debian-cloud/debian-12"

# Set Linux username
username = "tux"


# Generate password
def genPassword():
    password = ""
    passwordList = string.ascii_letters
    passwordList += string.digits
    for i in range(12):
        password += random.choice(passwordList)
    return password


# Hash password for Linux
def hashPassword(password):
    password_hash = crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512))
    return password_hash


# Generate hostname
def genHostname():
    hostname = ""
    for i in range(8):
        hostname += random.choice(string.ascii_letters)
    return hostname


# Generate data
password = genPassword()
hostname = genHostname()
data = {}
data["username"] = username
data["password"] = hashPassword(password)
data["dnsname"] = hostname
data["image"] = image

# Print
print(f"Hostname: {hostname}")
print(f"Username: {username}")
print(f"Password: {password}")
json_data = json.dumps(data, indent=4, sort_keys=True)
print(f"JSON Message:\n{json_data}")

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
