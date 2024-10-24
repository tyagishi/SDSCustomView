// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDSCustomView",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SDSCustomView",
            targets: ["SDSCustomView"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/tyagishi/SDSCGExtension", from: "1.1.0"),
        .package(url: "https://github.com/tyagishi/SDSViewExtension", from: "4.2.0"),
        .package(url: "https://github.com/tyagishi/SDSDataStructure", from: "4.0.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.56.1"),
        .package(url: "https://github.com/nalexn/ViewInspector", branch: "0.10.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SDSCustomView",
            dependencies: ["SDSCGExtension", "SDSViewExtension", "SDSDataStructure"],
            plugins: [ .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins") ]
        ),
        .testTarget(
            name: "SDSCustomViewTests",
            dependencies: ["SDSCustomView", "ViewInspector"]),
    ]
)
