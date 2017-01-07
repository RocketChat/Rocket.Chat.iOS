#!/bin/bash

set -e

./Scripts/update_cocoapods.sh
./Scripts/update_xcpretty.sh
./Scripts/update_dependencies.sh
