# Madfish Sapling

[![npm](https://img.shields.io/npm/v/@airgap/sapling-wasm.svg?colorB=brightgreen)](https://www.npmjs.com/package/@airgap/sapling-wasm)
[![jitpack](https://img.shields.io/jitpack/v/github/madfish-solutions/madfish-sapling)](https://jitpack.io/#madfish-solutions/madfish-sapling)
[![spm](https://img.shields.io/github/v/tag/madfish-solutions/madfish-sapling?include_prereleases&label=spm)](https://github.com/madfish-solutions/madfish-sapling/releases)

Wasm, Android and iOS wrappers around [Zcash Rust crates](https://github.com/zcash/librustzcash).

## Project Overview

The project is divided into the following packages:
- `sapling` - common sources in Rust, provides C and Wasm bindings for [Zcash crates](https://github.com/zcash/librustzcash)
- `sapling-wasm` - a JavaScript library using Wasm bindings from the `sapling` package
- `sapling-android` - a native Android library using C bindings from the `sapling` package
- `sapling-ios` - a native iOS library using C bindings from the `sapling` package

## Sapling Wasm

The custom version of Sapling Wasm has not been released, use [Airgap Sapling Wasm](https://github.com/airgap-it/airgap-sapling?tab=readme-ov-file#sapling-wasm).

## Sapling Android

### Install

To add Android Madfish Sapling library into your project:

1. Ensure [Android NDK](https://developer.android.com/ndk) is supported in your project. 

2. Add the [JitPack](https://jitpack.io/) repository to your root `build.gradle` file:
  ```groovy
  allprojects {
    repositories {
      ...
      maven { url 'https://jitpack.io' }
    }
  }
  ```

1. Add the dependency:
  ```groovy
  def saplingVersion = "x.y.z"

  implementation "com.github.madfish-solutions:madfish-sapling:$saplingVersion"
  ```

## Sapling iOS

### Install

To add iOS Madfish Sapling into your project, add the package dependency:

#### Xcode

Open the `Add Package Dependency` window (as described in [the official guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)) and enter the Madfish Sapling GitHub repository URL:
```
https://github.com/madfish-solutions/madfish-sapling
```

#### Package.swift file

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/madfish-solutions/madfish-sapling", from: "x.y.z")
```

