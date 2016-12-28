#!/bin/bash

if which swiftlint >/dev/null; then
  swiftlint
else
    # lets try to install swift lint using homebrew
    if which brew >/dev/null; then
        if result=$(brew install swiftlint); then
            swiftlint
            exit 0
        else
            echo "Failed to install swiftlint using homebrew"
            echo "$result"
            exit 1
        fi
    else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
        exit 1
    fi
    exit 1
fi