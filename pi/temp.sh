#!/usr/bin/env bash

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

cd "$HOME/soda" || exit 9

# Import with Terraform generated variables file
# shellcheck source=/dev/null
source "variables.sh" || exit 9
# Set Google Credentials
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soda/pi-private-key.json"

python3 "temp.py"

# EOF