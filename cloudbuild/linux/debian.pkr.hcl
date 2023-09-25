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
 * Create custom Debian GNU/Linux OS image
 *****************************************************************************/

# https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute
source "googlecompute" "debian" {
  communicator            = "ssh"
  ssh_username            = "packer"
  ssh_private_key_file    = "./ssh.key"
  project_id              = var.project
  instance_name           = "packer-debian-${var.build_id}"
  source_image_family     = "debian-12"
  machine_type            = var.machine_type
  zone                    = "${var.region}-${var.zone}"
  disk_size               = 25
  disk_type               = "pd-ssd"
  subnetwork              = "projects/${var.project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  image_name              = "custom-debian"
  image_description       = "Debian GNU/Linux 12 (Bookworm)"
  image_family            = "debian-12"
  image_storage_locations = [var.region]
  image_labels = {
    "public-image" = "false"
    "packer"       = "true"
    "build"        = var.build_id
  }
}

build {
  sources = ["sources.googlecompute.debian"]
  # https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible
  provisioner "ansible" {
    user                    = "packer"
    ssh_authorized_key_file = "./ssh.key.pub"
    use_proxy               = false
    playbook_file           = "./debian.yml"
  }
}
