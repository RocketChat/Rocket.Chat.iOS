#!/bin/bash

xcodebuild test-without-building \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,OS=$1,name=$2" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
