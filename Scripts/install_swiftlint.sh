#!/bin/bash

# https://alexplescan.com/posts/2016/03/03/setting-up-swiftlint-on-travis-ci/

# Installs the SwiftLint package.
# Tries to get the precompiled .pkg file from Github, but if that
# fails just recompiles from source.

SWIFTLINT_PKG_PATH="/tmp/SwiftLint.pkg"
# Make sure to always use the latest version
SWIFTLINT_PKG_URL="https://github.com/realm/SwiftLint/releases/download/0.15.0/SwiftLint.pkg"

wget -O $SWIFTLINT_PKG_PATH $SWIFTLINT_PKG_URL

if [ -f $SWIFTLINT_PKG_PATH ]; then
  echo "SwiftLint package exists! Installing it..."
  sudo installer -pkg $SWIFTLINT_PKG_PATH -target /
else
  echo "SwiftLint package doesn't exist. Compiling from source..." &&
  git clone https://github.com/realm/SwiftLint.git /tmp/SwiftLint &&
  cd /tmp/SwiftLint &&
  git submodule update --init --recursive &&
  sudo make install
fi