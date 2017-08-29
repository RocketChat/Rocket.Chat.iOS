# Rocket.Chat iOS native application

[![Build Status](https://travis-ci.org/RocketChat/Rocket.Chat.iOS.svg?branch=develop)](https://travis-ci.org/RocketChat/Rocket.Chat.iOS)
[![codecov](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS/branch/develop/graph/badge.svg)](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS)
[![documentation](https://RocketChat.github.io/Rocket.Chat.iOS/badge.svg)](https://RocketChat.github.io/Rocket.Chat.iOS)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/09aed95b69c14cb88521890335633acc)](https://www.codacy.com/app/RocketChat/Rocket-Chat-iOS)

## Rocket.Chat.iOS.SDK

### Requirements

- Swift 3
- iOS 10.0+

### Install with CocoaPods

Add this to your `Podfile`

  `pod 'RocketChat'`

## Usage

A simple livechat example

```swift
import RocketChat
RocketChat.configure(withServerURL: URL(string: "demo.rocket.chat")!) {
    let livechat = RocketChat.livechat()
    livechat.initiate {
        guard let department = livechat.departments.first else {
            return
        }
        livechat.registerGuestAndLogin(withEmail: email, name: name, toDepartment: department, message: message) {
            DispatchQueue.main.async {
                guard let controller = livechat.getLiveChatViewController() else {
                    return
                }
                someController.present(controller, animated: true, completion: nil)
            }
        }
    }
}
```

See more with [`SDKExample` app](https://github.com/RocketChat/Rocket.Chat.iOS/tree/develop/SDKExample), also [API Reference](https://RocketChat.github.io/Rocket.Chat.iOS).

## Get it from the store

[![Rocket.Chat on Apple AppStore](https://user-images.githubusercontent.com/551004/29770691-a2082ff4-8bc6-11e7-89a6-964cd405ea8e.png)](https://itunes.apple.com/us/app/rocket-chat/id1148741252?mt=8)

## Reporting an Issue

[Github Issues](https://github.com/RocketChat/Rocket.Chat.iOS/issues) are used to track todos, bugs, feature requests, and more.
Please note we are still in very early stages development, so expect lots of bugs, etc. until we can reach a first alpha version.

## The app isn't connecting to your server?
Make sure your server supports WebSocket. These are the minimum requirements for Apache 2.4 and Nginx 1.3 or greater.

## Setting up a development environment

In case you're interested in playing around with the code or giving something back, here are some instructions on how to set up your project:

1. Install [CocoaPods](https://cocoapods.org)  (note that you will need to install at least Ruby 2.2.3 for this to work)

  `sudo gem install cocoapods`

2. Install all the Pods  (note that this will `git clone` the [CocoaPods github spec repos](https://github.com/CocoaPods/Specs) which may take up to an hour on slow link/machines)

  `pod install`

3. Open `Rocket.Chat.xcworkspace`
4. Run the project (⌘ + R)

### Code style

We use [swiftlint](https://github.com/realm/SwiftLint#installation) to enforce code style and best practices.
