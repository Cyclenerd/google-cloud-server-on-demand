# Custom Linux OS images

File for Google Cloud Build:

* `build.yml` : Build custom OS images with Packer

## Packer

* `versions.pkr.hcl` : Required Packer plugins
* `variables.pkr.hcl` : Variables

### Debian GNU/Linux

* `debian.pkr.hcl` : Packer template
* `debian.yml` : Ansible playbook

### Ubuntu LTS

* `ubuntu.pkr.hcl` : Packer template
* `debian.yml` : Ansible playbook

### Fedora Linux

* `fedora.pkr.hcl` : Packer template
* `fedora.yml` : Ansible playbook

### openSUSE

* `suse.pkr.hcl` : Packer template
* `suse.yml` : Ansible playbook

## Website

* `index.php` : Custom website for each image