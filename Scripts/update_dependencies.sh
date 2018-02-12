#!/bin/bash

set -e

-# Swiftlint
 -brew install swiftlint

# Update all external dependencies
pod repo update
pod install
