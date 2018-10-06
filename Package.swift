// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-upnp-app",
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/bjtj/swift-upnp-tools.git", from: "0.1.6"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "swift-upnp-app",
      dependencies: ["SwiftUpnpTools"]),
    .testTarget(
      name: "swift-upnp-appTests",
      dependencies: ["swift-upnp-app"]),
  ]
)
