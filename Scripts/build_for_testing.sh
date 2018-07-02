#!/bin/bash

xcodebuild clean build-for-testing \
    -workspace Rocket.Chat.xcworkspace \
    -sdk iphonesimulator \
    -configuration Release
    -scheme Rocket.Chat | xcpretty -c && exit ${PIPESTATUS[0]}
