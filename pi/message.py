#!/usr/bin/env python

# Copyright 2022 Nils Knieling
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

import string
import crypt
import json
import random

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
