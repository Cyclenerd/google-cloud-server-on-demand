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
 * Variables
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
  default     = "g1-small"
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

locals {
  // Split build ID, use first part as name
  name      = element(split("-", var.build_id), 0)
  timestamp = timestamp()
  today     = formatdate("YYYY-MM-DD", local.timestamp)
  expires   = "${var.expires}m"
  # Calculate when the instance should be destroyed
  # https://developer.hashicorp.com/terraform/language/functions/timeadd
  destroy = timeadd(local.timestamp, local.expires)
  # https://www.terraform.io/language/functions/formatdate
  destroy_month  = formatdate("M", local.destroy) # Month number with no padding, like "1" for January.
  destroy_day    = formatdate("D", local.destroy) # Day of month number with no padding, like "2".
  destroy_hour   = formatdate("h", local.destroy) # 24-hour number unpadded, like "2".
  destroy_minute = formatdate("m", local.destroy) # Minute within hour unpadded, like "5".
}

/*****************************************************************************
 * Google Provider
 *****************************************************************************/


provider "google" {
  project = var.project
  region  = var.region
  zone    = "${var.region}-${var.zone}"
}

/*****************************************************************************
 * GCE Instance
 *****************************************************************************/

# Reserve external static IP for VM
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "external-static-ip" {
  name   = "ip-${local.name}"
  region = var.region
}

# Create GCE instance (VM)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
resource "google_compute_instance" "vm" {
  name         = "gce-${local.name}"
  description  = "GCE instance (Terraform managed)"
  machine_type = var.machine_type
  zone         = "${var.region}-${var.zone}"
  labels = {
    "terraform" = "true"
    "build"     = var.build_id
    "created"   = local.today
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      size  = 25
      type  = "pd-balanced"
      image = var.image
    }
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    /*
    # Ephemeral public IP
    access_config {}
    */
    # Static IP
    access_config {
      nat_ip = google_compute_address.external-static-ip.address
    }
  }
  metadata_startup_script = "date > /startup.txt"
  metadata = {
    ssh-keys = "ansible:${file(var.ansible_ssh_pub_key)}"
  }

  service_account {
    # Custom service accounts that have cloud-platform scope and permissions granted via IAM Roles
    email  = var.sa-compute
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_address.external-static-ip]
}

/*****************************************************************************
 * DNS
 *****************************************************************************/

# Create DNS name with short Cloud Build ID
resource "google_dns_record_set" "a" {
  #name = "${local.name}.${google_dns_managed_zone.dns.dns-name}"
  #managed_zone = google_dns_managed_zone.dns.name
  name         = "${local.name}.${var.dns-domain}"
  managed_zone = var.dns-zone
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.vm.network_interface[0].access_config[0].nat_ip]
  depends_on   = [google_compute_instance.vm]
}

# Create DNS TXT record with long Cloud Build ID
resource "google_dns_record_set" "txt" {
  name         = "${local.name}.${var.dns-domain}"
  managed_zone = var.dns-zone
  type         = "TXT"
  ttl          = 300
  rrdatas      = [var.build_id]
  depends_on   = [google_compute_instance.vm]
}

# Create DNS alias with dns-name variable from Pub/Sub
resource "google_dns_record_set" "cname" {
  name         = "${var.dns-name}.${var.dns-domain}"
  managed_zone = var.dns-zone
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [google_dns_record_set.a.name]
  depends_on   = [google_dns_record_set.a]
}


/*****************************************************************************
 * Cloud Scheduler
 *****************************************************************************/

# Create Cloud Scheduler job to destroy GCE VM after N hours
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job
resource "google_cloud_scheduler_job" "destroy" {
  name        = "job-destroy-${local.name}"
  region      = var.scheduler-region
  description = "Scheduler to destroy build ${var.build_id} (Terraform managed)"
  # Cron tab:     minute                  hour                  day                  month                 day
  schedule = "${local.destroy_minute} ${local.destroy_hour} ${local.destroy_day} ${local.destroy_month} *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = var.pub-sub-destroy-topic
    data       = base64encode("{\"destroy\":\"${var.build_id}\"}")
  }

  depends_on = [google_compute_instance.vm]
}

/*****************************************************************************
 * PHP Website
 *****************************************************************************/

# Create small PHP website
resource "local_file" "php" {
  content  = <<-EOF
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hello from Slalom and Google</title>
    <style>
    body {
      background-color: #0C62FB;
      color: #FFFFFF;
      font-family: "Lucida Console", "Courier New", monospace;
    }
    </style>
    </head>
    <body>
      <h1>👋 Hello</h1>
      <p>I'm a web server in the Google Cloud region <i>${var.region}</i>.</p>
      <br>
      <p>My hostname is:                         <i><?php system('hostname', $retval); ?></i></p>
      <p>I'm running the operating system image: <i>${var.image}</i></p>
      <p>My detailed system information:         <i><?php system('uname -a', $retval); ?></i></p>
      <p>I'm online without a reboot since:      <i><?php system('uptime', $retval);   ?></i></p>
      <br><hr>
      <p><i><?php system('date', $retval); ?></i></p>
    </body>
    </html>
  EOF
  filename = "/workspace/index.php"
}

/*****************************************************************************
 * Output
 *****************************************************************************/

resource "local_file" "nat_ip" {
  content  = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
  filename = "/workspace/nat_ip.txt"
}

output "hostname" {
  description = "Hostename"
  value       = local.name
}

output "ip" {
  description = "Public IPv4 address"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}