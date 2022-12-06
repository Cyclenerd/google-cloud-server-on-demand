#!/usr/bin/env bash

# Shellcheck
shellcheck ./*.sh             || exit 9
shellcheck ../cloudbuild/*.sh || exit 9
shellcheck ../pi/*.sh         || exit 9

# YAML
yamllint ../cloudbuild/*.yml        || exit 9

# Ansible
ansible-lint ../cloudbuild/gce-vm-ansible.yml || exit 9
ansible-lint ../pi/pi-soda.yml                || exit 9

# Python
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../pi/*.py || exit 9
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-gcb-discord/*.py || exit 9

# Terraform
cd ../cloudbuild/                    || exit 9
terraform init && terraform validate || exit 9
cd ../gcp/                           || exit 9
terraform init && terraform validate || exit 9
cd ../t/                             || exit 9