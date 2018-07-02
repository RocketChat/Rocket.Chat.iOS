#!/bin/bash

xcodebuild clean build-for-testing \
    -workspace Rocket.Chat.xcworkspace \
    -sdk iphonesimulator \
    -D TEST \
    -scheme Rocket.Chat | xcpretty -c && exit ${PIPESTATUS[0]}
