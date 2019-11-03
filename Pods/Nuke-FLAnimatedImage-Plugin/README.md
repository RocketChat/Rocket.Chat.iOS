<p align="center"><img src="https://cloud.githubusercontent.com/assets/1567433/13918338/f8670eea-ef7f-11e5-814d-f15bdfd6b2c0.png" height="180"/>

<p align="center">
<a href="https://cocoapods.org"><img src="https://img.shields.io/cocoapods/v/Nuke-Alamofire-Plugin.svg"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

[FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) plugin for [Nuke](https://github.com/kean/Nuke) that allows you to load and display animated GIFs with [smooth scrolling performance](https://www.youtube.com/watch?v=fEJqQMJrET4) and low memory footprint. You can see it for yourself in a demo, included in the project.

## Usage

All you need to do to enable GIF support is set `isAnimatedImageDataEnabled` to `true`. After you do that, you can start using `FLAnimatedImageView`.

```swift
ImagePipeline.Configuration.isAnimatedImageDataEnabled = true

let view = FLAnimatedImageView()
Nuke.loadImage(with: URL(string: "http://.../cat.gif")!, into: view)
```

## Installation

### Manually

The entire plugin is a single file with 23 lines of code which you can just copy into your project without having to deal with extra framework dependencies.

### [CocoaPods](http://cocoapods.org)

To install the plugin add a dependency to your Podfile:

```ruby
# source 'https://github.com/CocoaPods/Specs.git'
# use_frameworks!

pod "Nuke-FLAnimatedImage-Plugin"
```

### [Carthage](https://github.com/Carthage/Carthage)

To install the plugin add a dependency to your Cartfile:

```
github "kean/Nuke-FLAnimatedImage-Plugin"
```

## Minimum Requirements

| Nuke FLAnimatedImage Plugin            | Swift                 | Xcode                | Platforms   |
|----------------------------------------|-----------------------|----------------------|-------------|
| Nuke FLAnimatedImage Plugin 6.1        | Swift 4.2 – 5.0       | Xcode 10.1 – 10.2    | iOS 10.0    |
| Nuke FLAnimatedImage Plugin 6.0        | Swift 4.0 – 4.2       | Xcode 9.2 – 10.1     | iOS 9.0     | 


## Dependencies

- [Nuke ~> 7.5](https://github.com/kean/Nuke)
- [FLAnimatedImage ~> 1.0](https://github.com/Flipboard/FLAnimatedImage)

## License

Nuke is available under the MIT license. See the LICENSE file for more info.
