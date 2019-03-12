# Contributing Guidelines - Rocket.Chat.iOS 

Great to have you here! Here are a few ways you can help make this project better!

## TestFlight builds

If you're reporting issues, you may request for TestFlight (beta) access via [open.rocket.chat](https://open.rocket.chat/channel/iosnativeapp).

If you have a TestFlight pre-release installed you have following options:

- Open FLEX via Sidebar > Dropdown > My Account
  - You can open the Menu and have a peek on the Network traffic if some action was not executing as promised
- Report issue via TestFlight directly, but [Github Issues](https://github.com/RocketChat/Rocket.Chat.iOS/issues) are preferred as everybody can see the Issues and may fix them.

## Setting up a development environment

In case you're interested in playing around with the code or giving something back, here are some instructions on how to set up your project:

### Pre-requisites

1. A macOS machine
2. Xcode 9.3.x or higher (Swift 4.1)

Before you begin, you should already have the Xcode downloaded and set up correctly. You can find a guide on how to do this here: [Setting up Xcode](https://developer.apple.com/xcode/)

### Development Setup

##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Steps to install Cocoapods (one time installation)

- Run `sudo gem install cocoapods` to install the latest version of cocoapods. To install cocoapods from HomeBrew, `brew install cocoapods`.

-  Next, run `pod setup` for setting up cocoapods master repo.

### Setting up the iOS Project

1. Download the _Rocket.Chat.iOS_ project source. You can do this either by forking and cloning the repository (recommended if you plan on pushing changes) or by downloading it as a ZIP file and extracting it. OR
```
$ git clone https://github.com/RocketChat/Rocket.Chat.iOS
```

2. Navigate to the unzipped folder and run the following commands-</br>
`pod deintegrate`</br>
`pod install`</br>
`pod update`</br>

3. Open `Rocket.Chat.xcworkspace` from the folder.

4. Build the project (⌘+B) and check for any errors.

5. Run the app (⌘+R).and test it.

Also refer to [Guidelines](#project.pbxproj) for modifying files.

## Issues needing help

Didn't found a bug or want a new feature not already reported? Check out [the issues with "help wanted"](https://github.com/RocketChat/Rocket.Chat.iOS/labels/help%20wanted) or other issues, for those no branch exists.

## Guidelines

### project.pbxproj

Don't change this file unless required (added files). This includes signing of the application itself. The "Team" will be red in the `Rocket.Chat.xcodeproj`, that's fine.

<img src=https://user-images.githubusercontent.com/193273/35477109-ad451daa-03bc-11e8-828b-9238bdda438e.png width=500>

### New to Swift?

Search engines like Google help most of the times or consider searching on platforms like [StackOverflow](https://stackoverflow.com/search?q=)

### Code style

We use [swiftlint](https://github.com/realm/SwiftLint#installation) to enforce code style and best practices. Setup Xcode to use **4 spaces** as indentation. For general styling refer to [this Swift style guide](https://github.com/raywenderlich/swift-style-guide).

### Tests

Before opening a Pull Request/pushing to an existing PR run your code using the :wrench: Test (⌘ + U). If you're writing new code, testunits are welcome. Have a look at `Rocket.ChatTests` and increase our [![codecov](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS/branch/develop/graph/badge.svg)](https://codecov.io/gh/RocketChat/Rocket.Chat.iOS).

Test your changes on different device sizes (iPad/iPhone) and check if the layout is appropriate.

Also check if VoiceOver and different font sizes work well (Device Settings > General > Accessibility).

### Pull Request

As soon as your changes are ready, you can open a Pull Request.

The title of the request should be descriptive, including either [NEW], [IMPROVEMENT] or [FIX] at the beginning, e.g. `[FIX] App crashing on startup`.

Also describe the changes you made on the message mentioning `@RocketChat/ios`. If there is an open issue which your changes will solve, include `Closes/Fixes/Resolves #issue`. For multiple issues repeat the sequence (`Closes #issue1 #issue2` will only close `#issue1` on merge).

You may share working results prior to finishing, please include [WIP] in the title. This way anyone can look at your code: you can ask for help within the PR if you don't know how to solve a problem.

If you are committing work in progress, please name your branche like `some-branch-name-wip`. The `*-wip`/`wip-*`/`wip/*` tells our CI to skip this branch for builds. Once you are ready, you can rename your branch and push your working commits (only a push will trigger CI). This makes it easier to save time and resources on continuous integration.

If working on docs or nothing related to the sourcecode of the App, you may want to name your branch `*-docs`/`docs-*`/`docs/*`. This has the same effect as `wip` above.

Your PR is automatically inspected by various tools, check their response and try to improve your code accordingly. Requests that fail to build or have wrong coding style won't be merged.
