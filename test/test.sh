#!/usr/bin/env bash

# Versions
lsb_release -a
echo
shellcheck --version || exit 9
echo
terraform --version || exit 9
tflint --version    || exit 9
echo
yamllint --version || exit 9
echo
ansible --version              || exit 9
ansible-lint --version         || exit 9
ansible-galaxy collection list || exit 9
echo
flake8 --version || exit 9

echo
echo "Testing..."

# Shellcheck
echo
echo "Shellcheck:"
shellcheck ./*.sh             || exit 9
shellcheck ../cloudbuild/*.sh || exit 9
shellcheck ../pi/*.sh         || exit 9
echo "OK"

# YAML
echo
echo "YAML:"
yamllint ../pi/*.yml || exit 9
yamllint ../cloudbuild/*.yml || exit 9
yamllint ../cloudbuild/linux/*.yml || exit 9
echo "OK"

# Ansible
echo
echo "Ansible:"
ansible-lint ../pi/pi-soda.yml              || exit 9
ansible-lint ../cloudbuild/setup.yml        || exit 9
ansible-lint ../cloudbuild/linux/debian.yml || exit 9
ansible-lint ../cloudbuild/linux/fedora.yml || exit 9
ansible-lint ../cloudbuild/linux/suse.yml   || exit 9
echo "OK"

# Python
echo
echo "Python:"
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../pi/*.py || exit 9
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-gcb-discord/*.py || exit 9
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-temp-monitoring/*.py || exit 9
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../gcp/cloudfunction-count/*.py || exit 9
echo "OK"

# Terraform
echo
echo "Terraform:"
cd ../cloudbuild/                    || exit 9
terraform init && terraform validate || exit 9
cd ../gcp/                           || exit 9
terraform init && terraform validate || exit 9
cd ../test/                          || exit 9
terraform fmt -recursive -check -diff -no-color || exit 9
tflint --recursive --no-color || exit 9
echo "OK"

echo
echo "DONE"