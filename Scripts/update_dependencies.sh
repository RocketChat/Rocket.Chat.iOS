#!/bin/bash

set -e

# Update all external dependencies
pod repo update
pod install

cd SDKExample
pod install
