#!/bin/bash

set -e

# Gems & Swiftlint
gem install bundler
gem install xcpretty
gem install cocoapods
brew install swiftlint

# Update all external dependencies
curl https://cocoapods-specs.circleci.com/fetch-cocoapods-repo-from-s3.sh | bash -s cf
pod install
