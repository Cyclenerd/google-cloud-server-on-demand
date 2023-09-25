/*
 * Copyright 2022-2023 Nils Knieling
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
 * Variables for Terraform
 *****************************************************************************/

variable "build_id" {
  type        = string
  nullable    = false
  description = "Google Cloud Build ID (is passed by Cloud Build)"
}

variable "project" {
  type        = string
  nullable    = false
  description = "Google Cloud project ID"
}

variable "region" {
  type        = string
  nullable    = false
  description = "Google Cloud region"
}

variable "zone" {
  type        = string
  nullable    = false
  description = "Zone in Google Cloud region"
}

variable "scheduler-region" {
  type        = string
  nullable    = false
  description = "Google Cloud region for Google Cloud scheduler"
}

variable "expires" {
  type        = string
  nullable    = false
  description = "Duration until the VM is destroyed"
}

variable "network" {
  type        = string
  nullable    = false
  description = "VPC network"
}

variable "subnetwork" {
  type        = string
  nullable    = false
  description = "VPC subnetwork"
}

variable "dns-name" {
  type        = string
  nullable    = false
  description = "DNS name for VM"
  default     = "cname-for-a-dns-name"
}

variable "dns-zone" {
  type        = string
  nullable    = false
  description = "Google Cloud DNS managed zone name"
}

variable "dns-domain" {
  type        = string
  nullable    = false
  description = "Google Cloud DNS domain for managed zone"
}

variable "pub-sub-destroy-topic" {
  type        = string
  nullable    = false
  description = "Pub/sub topic to destroy GCE instance build after N hours"
}

variable "sa-compute" {
  type        = string
  nullable    = false
  description = "SA for Compute Engine instances"
}

variable "machine_type" {
  type        = string
  nullable    = false
  description = "Google Compute Engine machine type"
  default     = "e2-micro"
}

variable "image" {
  type        = string
  nullable    = false
  description = "Google Compute Engine operating system image"
  default     = "debian-cloud/debian-12"
}

variable "ansible_ssh_pub_key" {
  type        = string
  nullable    = false
  description = "SSH public key for Ansible"
  default     = "/workspace/ssh.key.pub"
}
