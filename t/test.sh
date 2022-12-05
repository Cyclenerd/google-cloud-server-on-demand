#!/usr/bin/env bash

shellcheck ../cloudbuild/*.sh
shellcheck ../pi/*.sh
flake8 --ignore=W292 --max-line-length=127 --show-source --statistics ../pi/*.py