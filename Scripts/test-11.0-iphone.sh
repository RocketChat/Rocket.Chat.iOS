#!/bin/bash

xcodebuild clean test \
    -workspace Rocket.Chat.xcworkspace \
    -scheme Rocket.Chat \
    -destination "platform=iOS Simulator,OS=11.0,name=iPhone 8" \
    -enableCodeCoverage YES | xcpretty -c && exit ${PIPESTATUS[0]}

bash <(curl -s https://codecov.io/bash) -J 'Rocket.Chat'
