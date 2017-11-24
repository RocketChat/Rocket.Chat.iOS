#!/bin/bash

xcodebuild clean test \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,os=10.3.1,name=iPad Air 2" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
