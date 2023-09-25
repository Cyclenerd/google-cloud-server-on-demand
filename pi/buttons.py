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

from datetime import datetime as dt
from datetime import timedelta
# https://python-escpos.readthedocs.io/en/latest/
from escpos.printer import File
from google.cloud import pubsub_v1
from gpiozero import LED, Button
from time import sleep
import copy
import crypt
import google
import json
import os
import random
import sys
import re
import sqlite3

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

if expires:
    print(f"Expires: {expires}")
    # Convert to int for timedelta
    expires = int(expires)
else:
    sys.exit("[ERROR] Please check MY_EXPIRES.")

# MY_MAX_VMS
max_vms = ""
try:
    max_vms = os.environ['MY_MAX_VMS']
except KeyError:
    sys.exit("[ERROR] Environment variable MY_MAX_VMS not set!")

if max_vms:
    print(f"Maximum number of VMs to create: {max_vms}")
    # Convert to int
    max_vms = int(max_vms)
else:
    sys.exit("[ERROR] Please check MY_MAX_VMS.")

# Printer
p = File("/dev/usb/lp0")

# Database
db_file = "database.db"

# Create database if not exists
connection = sqlite3.connect(db_file)
# Create a cursor to execute queries.
sql = connection.cursor()

# LEDs
blue = LED(26)
yellow = LED(19)
red = LED(13)
green = LED(6)

# Buttons
b1 = Button(17)
b2 = Button(27)
b3 = Button(22)
b4 = Button(23)

# Letters that are difficult to mix up
characterList = "abcdefghjkmnpqrstuvwxyz"


def publish(data):
    # Remove cleartext password
    publish_data = copy.copy(data)
    del publish_data["cleartext"]
    # Remove unnecessary data
    del publish_data["dnsfqdn"]
    del publish_data["expires"]
    # Google Pub/Sub Client
    publisher = ""
    try:
        publisher = pubsub_v1.PublisherClient()
    except google.auth.exceptions.DefaultCredentialsError:
        print("[ERROR] Could not determine credentials.")
        return
    except Exception:
        print("[ERROR] Unknown error in Pub/Sub client.")
        return
    # Publish message
    try:
        topic_path = publisher.topic_path(project_id, topic_id)
        # Message body must be a bytestring
        json_object = json.dumps(publish_data)
        message = str(json_object).encode("utf-8")
        future = publisher.publish(topic_path, message)
        publish = future.result(timeout=60)
        print(f"Published message ID: {publish}")
        return 1
    except Exception:
        print("[ERROR] Cannot publish message!")
        return


# Functions for LEDs
def ledsOn():
    blue.on()
    yellow.on()
    red.on()
    green.on()


# Turn all LED off
def ledsOff():
    blue.off()
    yellow.off()
    red.off()
    green.off()


# Party LED flashing
def ledParty():
    print("Party!")
    for i in range(6):
        sleep(1)
        ledsOff()
        sleep(1)
        ledsOn()


# Blink one LED
def ledBlink(int_nr):
    ledsOff()
    if int_nr == 1:
        blue.blink(1, 1)
    elif int_nr == 2:
        yellow.blink(1, 1)
    elif int_nr == 3:
        red.blink(1, 1)
    elif int_nr == 4:
        green.blink(1, 1)


# Generate username
def genUsername():
    usernames = [
        "anakin",
        "vader",
        "luke",
        "leia",
        "han",
        "ben",
        "kylo",
        "rey",
        "poe",
        "finn",
        "boba",
        "yoda",
        "grievous",
        "chewbacca"
    ]
    return random.choice(usernames)


# Generate password
def genPassword():
    password = ""
    passwordList = characterList
    passwordList += "23456789"
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
        hostname += random.choice(characterList)
    return hostname


# Use custom OS image
def getImage(int_nr):
    image = "custom-debian"
    # Blue
    if int_nr == 1:
        image = "custom-fedora"
        #image = "fedora-cloud/fedora-cloud-38"
    # Yellow
    elif int_nr == 2:
        image = "custom-ubuntu"
        #image = "ubuntu-os-cloud/ubuntu-2204-lts"
    # Red
    elif int_nr == 3:
        image = "custom-debian"
        #image = "debian-cloud/debian-12"
    # Green
    elif int_nr == 4:
        image = "custom-suse"
        #image = "opensuse-cloud/opensuse-leap"
    return image


def outputData(data):
    print("JSON:\n")
    json_data = json.dumps(data, indent=4, sort_keys=True)
    print(json_data)


def printNewline():
    p.set(width=1, height=1, align='left')
    p.text("\n")


def printTitle(title):
    p.set(width=2, height=1, align='left')
    p.text(title)
    printNewline()


def printText(text):
    p.set(width=1, height=1, align='left')
    p.text(text)
    printNewline()


def printTitleText(title, text):
    printTitle(title)
    printText(text)


def printData(data):
    print("Print data on paper\n")
    username = data["username"]
    password = data["cleartext"]
    hostname = data["dnsfqdn"]
    shutdown = data["expires"]
    image = data["image"]
    # Nice OS image name
    image_name = "Debian GNU/Linux"
    if (image.__contains__('debian')):
        image_name = "Debian GNU/Linux"
    elif (image.__contains__('ubuntu')):
        image_name = "Ubuntu"
    elif (image.__contains__('fedora')):
        image_name = "Fedora Linux"
    elif (image.__contains__('suse')):
        image_name = "openSUSE"
    # Logo
    p.image("image.png")
    printNewline()
    printNewline()
    p.set(width=4, height=4, align='center')
    p.text("FREE VM\n")
    p.set(width=1, height=1, align='center')
    p.text("Your fully automated VM in\n")
    p.text("Google Cloud Platform\n")
    printNewline()
    printTitle("SSH (Shell)")
    printText("Connect to this VM with your")
    printText("favorite SSH client...")
    printNewline()
    # Text
    printTitleText("Hostname", hostname)
    printNewline()
    printTitleText("Username", username)
    printNewline()
    printTitleText("Password", password)
    printNewline()
    printTitleText("VM expires at", shutdown)
    printNewline()
    printTitleText("Operating System", image_name)
    printNewline()
    # QR Code
    printTitle("HTTP")
    printText("There is also a nice website.")
    printText("Visit it with your browser...")
    p.qr(f"http://{hostname}/", size=8)
    printNewline()
    printNewline()
    printTitle("Note")
    printText("Since you have this paper in")
    printText("your hand, a VM is started and")
    printText("freshly installed for you. It is")
    printText("not a hot standby machine or a")
    printText("preconfigured image. Give it")
    printText("about 4min. until automation has")
    printText("created everything.")
    printNewline()
    # Slalom website
    printTitle("About Slalom")
    printText("Learn more about Slalom & Google")
    p.qr("https://bit.ly/slalom-google", size=8)
    printNewline()
    printNewline()
    printTitle("One Tree Planted")
    printText("Thank you for spending time with")
    printText("us! For every VM created at")
    printText("DIGITAL X we will plant a tree")
    printText("through the organization")
    printText("One Tree Planted.")
    # Cut
    for i in range(4):
        printNewline()


# Functions for buttons
def button(int_nr):
    str_nr = str(int_nr)
    now = dt.now()
    shutdown = now + timedelta(minutes=expires)
    str_now = now.strftime("%Y-%m-%d %H:%M:%S")
    str_shutdown = shutdown.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[Button {str_nr}] {str_now}")
    ledBlink(int_nr)
    # Count rows in table
    int_timeframe = int((now - timedelta(minutes=expires)).timestamp())
    sql.execute("SELECT COUNT(button) FROM soda WHERE time > ?", (int_timeframe,))
    count = int(sql.fetchone()[0])
    print(f"[SQL] {count} VMs in timeframe.")
    if count > max_vms:
        print("[ERROR] Too many VMs in timeframe.")
        printText("OUT OF QUOTA!")
        # Get oldest VM in timeframe
        sql.execute("SELECT MIN(time) FROM soda WHERE time > ?", (int_timeframe,))
        oldest = dt.fromtimestamp(sql.fetchone()[0])
        # Calculate next try
        next_try = oldest + timedelta(minutes=expires + 5)
        next = next_try.strftime("%Y-%m-%d %H:%M:%S")
        printText(f"Try again at {next}")
        # Cut
        for i in range(4):
            printNewline()
        ledParty()
        return
    # Generate data
    username = genUsername()
    password = genPassword()
    hostname = genHostname()
    data = {}
    data["username"] = username
    data["cleartext"] = password
    data["password"] = hashPassword(password)
    data["dnsname"] = hostname
    data["dnsfqdn"] = f"{hostname}.{dns_domain}"
    data["image"] = getImage(int_nr)
    data["expires"] = str_shutdown
    # Print
    outputData(data)
    # Publish and print
    if publish(data):
        printData(data)
    # Insert the data into the table.
    sql.execute(
        "INSERT INTO soda (button, time) VALUES (?, ?)",
        (int_nr, int(now.timestamp()))
    )
    # Commit the changes to the database.
    connection.commit()
    # Party
    ledParty()


# ON
ledsOn()

# Wait for input...
print("\nWait for button input... ([Ctrl]+[C] to cancel)\n")
while True:
    # Check if button is pressed
    if b1.is_pressed:
        button(1)
    elif b2.is_pressed:
        button(2)
    elif b3.is_pressed:
        button(3)
    elif b4.is_pressed:
        button(4)
    sleep(0.1)
