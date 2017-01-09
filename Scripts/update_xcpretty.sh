#!/bin/bash

set -e

# Update xcpretty if necessary
function checkXcpretty {
    echo "Checking xcpretty version"
    
    XCPRETTY_LOCAL_VERSION=$(gem list | grep xcpretty | head -n 1 | grep  -o "\d.\d.\d" | head -n 1)
    XCPRETTY_REMOTE_VERSION=$(gem search xcpretty | grep xcpretty | head -n 1 | grep  -o "\d.\d.\d" | head -n 1)

    if [ "$XCPRETTY_REMOTE_VERSION" \> "$XCPRETTY_LOCAL_VERSION" ]; then
        echo "Updating xcpretty to $XCPRETTY_REMOTE_VERSION"
        updateXcpretty
    fi
}

function updateXcpretty {
    gem install xcpretty -N --no-ri --no-rdoc --quiet
}

# Update all external dependencies
function updateDependencies {
    pod repo update
}

checkXcpretty