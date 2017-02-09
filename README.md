# Rocket.Chat.iOS

[![Build Status](https://travis-ci.org/RocketChat/Rocket.Chat.iOS.svg?branch=develop)](https://travis-ci.org/RocketChat/Rocket.Chat.iOS)
[![codecov](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS/branch/develop/graph/badge.svg)](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/09aed95b69c14cb88521890335633acc)](https://www.codacy.com/app/RocketChat/Rocket-Chat-iOS)

Rocket.Chat Native iOS Application

## Reporting an Issue

[Github Issues](https://github.com/RocketChat/Rocket.Chat.iOS/issues) are used to track todos, bugs, feature requests, and more.
Please note we are still in very early stages development, so expect lots of bugs, etc. until we can reach a first alpha version.

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
