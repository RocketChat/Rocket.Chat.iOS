#!/bin/bash

set -e

# Update cocoapods if necessary
function checkPods {
    echo "Checking cocospods version"
    
    PODS_LOCAL_VERSION=$(gem list | grep cocoapods | head -n 1 | grep  -o "\d.\d.\d" | head -n 1)
    PODS_REMOTE_VERSION=$(gem search cocoapods | grep cocoapods | head -n 1 | grep  -o "\d.\d.\d" | head -n 1)

    if [ "$PODS_REMOTE_VERSION" \> "$PODS_LOCAL_VERSION" ]; then
        echo "Updating cocoapods to $PODS_REMOTE_VERSION"
        updatePods
    fi
}

function updatePods {
    gem install cocoapods --no-rdoc --no-ri --no-document --quiet
}

checkPods