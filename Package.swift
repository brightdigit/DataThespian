// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataThespian",
    platforms: [.iOS(.v17), .macCatalyst(.v17), .macOS(.v14), .tvOS(.v17), .visionOS(.v1), .watchOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataThespian",
            targets: ["DataThespian"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/brightdigit/FelinePine.git", from: "1.0.0-beta.2"),
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataThespian",
            dependencies: ["FelinePine"]
        ),
        .testTarget(
            name: "DataThespianTests",
            dependencies: [
                "DataThespian",
                .product(name: "Testing", package: "swift-testing"),
            ]
        )
    ]
)
