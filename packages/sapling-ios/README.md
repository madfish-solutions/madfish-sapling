# Madfish Sapling iOS

[![release](https://img.shields.io/github/v/tag/madfish-solutions/madfish-sapling?include_prereleases)](https://github.com/madfish-solutions/madfish-sapling/releases)

An iOS wrapper around [Zcash Rust crates](https://github.com/zcash/librustzcash).

## Install

To add iOS Madfish Sapling into your project, add the package dependency:

### Xcode

Open the `Add Package Dependency` window (as described in [the official guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)) and enter the Madfish Sapling GitHub repository URL:
```
https://github.com/madfish-solutions/madfish-sapling
```

### Package.swift file

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/madfish-solutions/madfish-sapling", from: "x.y.z")
```


## Development

### Update C Bindings
To update the C bindings from the core `sapling` package run:
```bash
# $ pwd
# <project-dir>/packages/sapling-ios

$ ./build-ffi.sh
```
