#!/bin/bash

swiftlint
xcodebuild clean test \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,name=iPhone 7" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
    