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
 * Create custom Ubuntu LTS OS image
 *****************************************************************************/

# https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute
source "googlecompute" "ubuntu" {
  communicator            = "ssh"
  ssh_username            = "packer"
  ssh_private_key_file    = "./ssh.key"
  project_id              = var.project
  instance_name           = "packer-ubuntu-${var.build_id}"
  source_image_family     = "ubuntu-2204-lts"
  machine_type            = var.machine_type
  zone                    = "${var.region}-${var.zone}"
  disk_size               = 25
  disk_type               = "pd-ssd"
  subnetwork              = "projects/${var.project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  image_name              = "custom-ubuntu"
  image_description       = "Ubuntu 22.04 LTS (Jammy Jellyfish)"
  image_family            = "ubuntu-2204-lts"
  image_storage_locations = [var.region]
  image_labels = {
    "public-image" = "false"
    "packer"       = "true"
    "build"        = var.build_id
  }
}

build {
  sources = ["sources.googlecompute.ubuntu"]
  # https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible
  provisioner "ansible" {
    user                    = "packer"
    ssh_authorized_key_file = "./ssh.key.pub"
    use_proxy               = false
    # Ubuntu is based on Debian. We can use the same playbook.
    playbook_file = "./debian.yml"
  }
}
