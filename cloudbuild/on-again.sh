#!/bin/bash

# Copyright 2022 Nils Knieling. All Rights Reserved.
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
# Start a stopped Google Compute Engine instance (virtual machine)
#
# bash cloudbuild-on-again.sh <INSTANCE-ID> <ZONE> <PROJECT-ID>
#

MY_RETRY=0
MY_MAX_RETRY=10
MY_SLEEP_SEC=30

MY_INSTANCE_ID="$1"
MY_ZONE="$2"
MY_PROJECT_ID="$3"

echo "» START INSTANCE"
echo "Instance ID : $MY_INSTANCE_ID"
echo "Zone        : $MY_ZONE"
echo "Project ID  : $MY_PROJECT_ID"
echo

while [ "$MY_RETRY" -le "$MY_MAX_RETRY" ]
do
	if gcloud compute instances describe "$MY_INSTANCE_ID" --zone="$MY_ZONE" --project="$MY_PROJECT_ID" --format="text(status)" | grep "TERMINATED"; then
		echo "Restart: Instance is terminated, try turning it back on..."
		if gcloud compute instances start "$MY_INSTANCE_ID" --zone="$MY_ZONE" --project="$MY_PROJECT_ID"; then
			# Instance is running
			exit 0
		else
			# Can not start instance
			exit 9
		fi
	fi
	echo "Test '$MY_RETRY' from '$MY_MAX_RETRY': Instance not terminated, sleeping for '$MY_SLEEP_SEC' seconds..."
	sleep "$MY_SLEEP_SEC"
	MY_RETRY=$((MY_RETRY+1))
done

echo "[ERROR] Instance is not terminated. Maximum attempts and time expired!"
exit 1