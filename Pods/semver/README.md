## Swift Semantic Versioning Library

[![Build Status](https://travis-ci.org/weekwood/Semver.Swift.svg)](https://travis-ci.org/weekwood/Semver.Swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/semver.svg)]()

Semver.swift is described by the v2.0.0 specification found at http://semver.org/.

### Usage

```
Semver.valid("1.2.3") // true
Semver.valid("a.b.c") // false
Semver.clean("  =v1.2.3   ") // '1.2.3'
Semver.gt("1.2.3", "9.8.7") // false
Semver.lt("1.2.3", "9.8.7") // true
Semver.gte("1.2.3", "9.8.7") // false
Semver.lte("1.2.3", "9.8.7") // true
Semver.eq("1.2.3", "9.8.7") // false
```

### Author

di wu, di.wu@me.com

### License

Semver.swift is available under the MIT license. See the LICENSE file for more info.
