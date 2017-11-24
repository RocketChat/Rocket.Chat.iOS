#!/bin/bash

xcodebuild clean test \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,os=11.0,name=iPhone 8" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
