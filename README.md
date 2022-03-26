# IMViewPager

![Pod Version](https://img.shields.io/cocoapods/v/IMViewPager.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/IMViewPager.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/IMViewPager.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`IMViewPager` is a container view controller that manages navigation between pages of content, where a child view controller manages each page on iOS.

## Requirements

- iOS 10.0+
- Xcode 11+
- Swift 5.0+

## Installation

### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects, which automates and simplifies the process of using 3rd-party libraries like `IMViewPager` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'IMViewPager'
```

If you want to use the latest features of `IMViewPager` use normal external source dependencies.

```ruby
pod 'IMViewPager', :git => 'https://github.com/immortal-it/IMViewPager.git'
```

This pulls from the `main` branch directly.

Second, install `IMViewPager` into your project:

```ruby
pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate IMViewPager into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "immortal-it/IMViewPager" ~> 0.0.1
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but IMViewPager does support its use on supported platforms.

Once you have your Swift package set up, adding IMViewPager as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/immortal-it/IMViewPager", .upToNextMajor(from: "0.0.1"))
]
```

### Manually

* Drag the `immortal-it/IMViewPager` folder into your project.

## Usage

(see sample Xcode project in `Demo`)

## License

`IMViewPager` is distributed under the terms and conditions of the [MIT license](https://github.com/immortal-it/IMViewPager/LICENSE).
