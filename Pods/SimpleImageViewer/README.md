![SimpleImageViewer](https://github.com/aFrogleap/SimpleImageViewer/blob/development/Documentation/banner.png)
[![CI Status](https://travis-ci.org/aFrogleap/SimpleImageViewer.svg?branch=master)](https://travis-ci.org/aFrogleap/SimpleImageViewer)
[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/SimpleImageViewer.svg?style=flat)](http://cocoadocs.org/docsets/SimpleImageViewer)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

A snappy image viewer with zoom and interactive dismissal transition. 

![SimpleImageViewer](https://github.com/aFrogleap/SimpleImageViewer/blob/development/Documentation/example.gif)

## Features

- [x] Double tap to zoom in/out
- [x] Interactive dismissal transition
- [x] Animate in from thumbnail image or fade in
- [x] Show activity indicator until image block is returned with new image
- [x] Animate from thumbnail image view with all kinds of [content modes](https://developer.apple.com/documentation/uikit/uiviewcontentmode)

## Get started!

### Carthage

To install SimpleImageViewer into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "aFrogleap/SimpleImageViewer" ~> 1.1.1
```

### Cocoapods

To install SimpleImageViewer into your Xcode project using [CocoaPods](http://cocoapods.org), specify it in your `Podfile`:

```ruby
pod 'SimpleImageViewer', '~> 1.1.1'
```

### Swift Package Manager

To install SimpleImageViewer into your Xcode project using [Swift Package Manager](https://swift.org/package-manager), specify it in your `Package.swift` file:

```swift
dependencies: [
    .Package(url: "https://github.com/aFrogleap/SimpleImageViewer.git", majorVersion: 1)
]
```

## Sample Usage
```swift
let configuration = ImageViewerConfiguration { config in
    config.imageView = someImageView
}

let imageViewerController = ImageViewerController(configuration: configuration)

present(imageViewerController, animated: true)

```

## Communication
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## License

SimpleImageViewer is available under the MIT license. See the LICENSE file for more info.

Copyright (c) 2017 aFrogleap
