#!/bin/bash

function lint() {
	echo "Running SwiftLint..."
	swiftlint
}

if which swiftlint >/dev/null; then
  lint
else
    # lets try to install swift lint using homebrew
    if which brew >/dev/null; then
        if $(brew update && brew install swiftlin); then
            lint
            exit 0
        else
            echo "Failed to install swiftlint using homebrew"
            exit 1
        fi
    else
        echo "error: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
        exit 1
    fi
    exit 1
fi