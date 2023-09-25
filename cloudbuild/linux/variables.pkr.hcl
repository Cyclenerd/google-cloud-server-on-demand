/*
 * Copyright 2023 Nils Knieling
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*****************************************************************************
 * Variables for Packer
 *****************************************************************************/

variable "build_id" {
  type        = string
  description = "Google Cloud Build ID (is passed by Cloud Build)"
}

variable "project" {
  type        = string
  description = "Google Cloud project ID"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "zone" {
  type        = string
  description = "Zone in Google Cloud region"
}

variable "machine_type" {
  type        = string
  description = "Google Compute Engine machine type"
  default     = "e2-standard-2"
}

variable "subnetwork" {
  type        = string
  description = "VPC subnetwork"
}
