#!/bin/bash

xcodebuild clean test \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,OS=10.3.1,name=iPhone 5" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
