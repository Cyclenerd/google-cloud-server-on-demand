#!/usr/bin/env bash

# Versions
lsb_release -a
echo
shellcheck --version || exit 9
echo
terraform --version  || exit 9
tflint --version || exit 9
echo
yamllint --version   || exit 9
echo
ansible --version              || exit 9
ansible-lint --version         || exit 9
ansible-galaxy collection list || exit 9
echo
flake8 --version || exit 9

echo
echo "Testing..."

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
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-temp-monitoring/*.py || exit 9
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-count/*.py || exit 9

# Terraform
cd ../cloudbuild/                    || exit 9
terraform init && terraform validate || exit 9
cd ../gcp/                           || exit 9
terraform init && terraform validate || exit 9
cd ../t/                             || exit 9
terraform fmt -recursive -check -diff -no-color || exit 9
tflint --recursive --no-color || exit 9