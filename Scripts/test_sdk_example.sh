#!/bin/bash

xcodebuild clean test \
    -workspace ./SDKExample/SDKExample.xcworkspace \
    -scheme SDKExample \
    -destination "platform=iOS Simulator,name=iPhone 7" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}
