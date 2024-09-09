// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  SwiftSetting.enableExperimentalFeature("AccessLevelOnImport"),
  SwiftSetting.enableExperimentalFeature("BitwiseCopyable"),
  SwiftSetting.enableExperimentalFeature("GlobalActorIsolatedTypesUsability"),
  SwiftSetting.enableExperimentalFeature("IsolatedAny"),
  SwiftSetting.enableExperimentalFeature("MoveOnlyPartialConsumption"),
  SwiftSetting.enableExperimentalFeature("NestedProtocols"),
  SwiftSetting.enableExperimentalFeature("NoncopyableGenerics"),
  SwiftSetting.enableExperimentalFeature("RegionBasedIsolation"),
  SwiftSetting.enableExperimentalFeature("TransferringArgsAndResults"),
  SwiftSetting.enableExperimentalFeature("VariadicGenerics"),

  SwiftSetting.enableUpcomingFeature("FullTypedThrows"),
  SwiftSetting.enableUpcomingFeature("InternalImportsByDefault")

 // SwiftSetting.unsafeFlags([
 //   "-Xfrontend",
 //   "-warn-long-function-bodies=100"
 // ]),
 // SwiftSetting.unsafeFlags([
 //   "-Xfrontend",
 //   "-warn-long-expression-type-checking=100"
 // ])
]

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
            dependencies: ["FelinePine"],
            swiftSettings: swiftSettings
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
