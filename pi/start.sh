#!/usr/bin/env bash

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

cd "$HOME/soda" || exit 9

# Import with Terraform generated variables file
# shellcheck source=/dev/null
source "variables.sh" || exit 9
# Set Google Credentials
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soda/pi-private-key.json"

# Wait 60sec
echo "Booting... (wait 30sec)"
sleep 30

# Check printer
if date "+%F %T %Z" > "/dev/usb/lp0"; then
	echo > "/dev/usb/lp0"
	echo '[X] Printer seems to be OK.'
else
	echo '[ERROR] Could not print current date. Please check printer!'
	# Blink for 1min and wait 2min before exit
	python3 "blink.py"
	sleep 120
	exit 9
fi

# Check Wi-Fi
if ip -br addr show wlan0 | grep "UP" > "/dev/null"; then
	echo '[X] Wi-Fi seems to be OK.'
else
	echo '[ERROR] Wi-Fi wlan0 is not up. Please check Wi-Fi!'
	python3 "blink.py"
	sleep 120
	exit 9
fi

echo
python3 "buttons.py"

# Wait 10min and than exit
sleep 600

# EOF