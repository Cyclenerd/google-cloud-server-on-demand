# Cloud Build

Files for Google Cloud Build:

* `copy-image.yml` : Copy container image from Docker Hub to Artifact Registry repository
* `create.yml` : Create a VM and everything that is required
	* `gce-vm-terraform.tf` : Create the infrastructure
	* `wait-for-ssh.sh` : Wait for the VM till it can be accessed via SSH
	* `gce-vm-ansible.yml` : Configure operating system and web server
* `destroy.yml` : Delete everything that belongs to a VM
* `on-again.yml` : Restart VM that was shut down by the user
	* `on-again.sh` : Turn VM back on
* `simulate-error.yml` : Simulate Cloud Build error