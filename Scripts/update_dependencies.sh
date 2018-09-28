#!/bin/bash
# RKS NOTE: Our CI is not using dependencies anymore.
# This file is being deprecated.

set -e

# Update all external dependencies
curl https://cocoapods-specs.circleci.com/fetch-cocoapods-repo-from-s3.sh | bash -s cf
bundle exec pod install
