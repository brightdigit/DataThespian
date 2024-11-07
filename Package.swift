// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swiftlint:disable explicit_acl explicit_top_level_acl
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
]

let package = Package(
  name: "DataThespian",
  platforms: [.iOS(.v17), .macCatalyst(.v17), .macOS(.v14), .tvOS(.v17), .visionOS(.v1), .watchOS(.v10)],
  products: [
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
// swiftlint:enable explicit_acl explicit_top_level_acl
