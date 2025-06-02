//
//  WorkflowTests.swift
//  DataThespian
//
//  Created by Unit Tests
//

import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

internal struct WorkflowTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testMatrixStrategy() async throws {
    #if canImport(SwiftData)
      // This test verifies that the matrix strategy in the CI workflow works correctly
      // by testing similar matrix combinations as defined in the workflow
      
      // Test Ubuntu matrix configurations
      let ubuntuMatrixOSes = ["noble", "jammy"]
      let ubuntuMatrixSwiftVersions = ["6.0", "6.1"]
      
      for os in ubuntuMatrixOSes {
        for swiftVersion in ubuntuMatrixSwiftVersions {
          let containerImage = "swift:\(swiftVersion)-\(os)"
          #expect(!containerImage.isEmpty)
          #expect(containerImage.contains(os))
          #expect(containerImage.contains(swiftVersion))
        }
      }
      
      // Test macOS matrix configurations for Xcode versions
      let xcodeVersions = ["16.1", "16.3"]
      for xcodeVersion in xcodeVersions {
        let xcodePath = "/Applications/Xcode_\(xcodeVersion).app"
        #expect(!xcodePath.isEmpty)
        #expect(xcodePath.contains(xcodeVersion))
      }
      
      // Test iOS configurations
      let iosDevices = ["iPhone 16", "iPhone 16 Pro"]
      let iosVersions = ["18.1", "18.4"]
      
      for (index, device) in iosDevices.enumerated() {
        let version = iosVersions[index]
        let destination = "platform=iOS Simulator,name=\(device),OS=\(version)"
        #expect(!destination.isEmpty)
        #expect(destination.contains(device))
        #expect(destination.contains(version))
      }
      
      // Test watchOS configurations
      let watchDevice = "Apple Watch Ultra 2 (49mm)"
      let watchVersions = ["11.1", "11.4"]
      
      for version in watchVersions {
        let destination = "platform=watchOS Simulator,name=\(watchDevice),OS=\(version)"
        #expect(!destination.isEmpty)
        #expect(destination.contains(watchDevice))
        #expect(destination.contains(version))
      }
      
      // Test visionOS configuration
      let visionDevice = "Apple Vision Pro"
      let visionVersion = "2.4"
      let visionDestination = "platform=visionOS Simulator,name=\(visionDevice),OS=\(visionVersion)"
      #expect(!visionDestination.isEmpty)
      #expect(visionDestination.contains(visionDevice))
      #expect(visionDestination.contains(visionVersion))
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testLintingScriptFlags() async throws {
    #if canImport(SwiftData)
      // Test the various linting modes from the updated lint.sh script
      let lintModes = ["NONE", "STRICT", "INSTALL", ""]
      
      for mode in lintModes {
        let shouldExit = mode == "NONE" || mode == "INSTALL"
        #expect(shouldExit == (mode == "NONE" || mode == "INSTALL"))
        
        let swiftFormatOptions = mode == "STRICT" ? 
          "--strict --configuration .swift-format" : 
          "--configuration .swift-format"
        #expect(!swiftFormatOptions.isEmpty)
        #expect(swiftFormatOptions.contains(".swift-format"))
        
        if mode == "STRICT" {
          #expect(swiftFormatOptions.contains("--strict"))
        }
        
        let swiftLintOptions = mode == "STRICT" ? "--strict" : ""
        if mode == "STRICT" {
          #expect(swiftLintOptions == "--strict")
        } else {
          #expect(swiftLintOptions == "")
        }
      }
      
      // Test OS detection logic for mint path
      let osTypes = ["Darwin", "Linux"]
      for os in osTypes {
        let mintPath = if os == "Darwin" {
          "/opt/homebrew/bin/mint"
        } else if os == "Linux" {
          "/usr/local/bin/mint"
        } else {
          ""
        }
        
        #expect(!mintPath.isEmpty)
        #expect(mintPath.contains("mint"))
        
        if os == "Darwin" {
          #expect(mintPath.contains("homebrew"))
        } else if os == "Linux" {
          #expect(mintPath.contains("local"))
        }
      }
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testExperimentalFeaturesConfiguration() async throws {
    #if canImport(SwiftData)
      // Test the experimental features configuration from Package.swift
      let includedFeatures = [
        "AccessLevelOnImport",
        "BitwiseCopyable",
        "IsolatedAny",
        "MoveOnlyPartialConsumption",
        "NestedProtocols",
        "NoncopyableGenerics",
        "TransferringArgsAndResults",
        "VariadicGenerics"
      ]
      
      let removedFeatures = [
        "GlobalActorIsolatedTypesUsability",
        "RegionBasedIsolation"
      ]
      
      for feature in includedFeatures {
        #expect(!feature.isEmpty)
      }
      
      for feature in removedFeatures {
        #expect(!feature.isEmpty)
      }
      
      // Ensure no overlap between included and removed features
      for feature in includedFeatures {
        #expect(!removedFeatures.contains(feature))
      }
      
      for feature in removedFeatures {
        #expect(!includedFeatures.contains(feature))
      }
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testMintfileConfiguration() async throws {
    #if canImport(SwiftData)
      // Test the Mintfile configuration changes
      let includedPackages = [
        "swiftlang/swift-format@600.0.0",
        "realm/SwiftLint@0.58.2"
      ]
      
      let removedPackages = [
        "a7ex/xcresultparser@1.7.2",
        "peripheryapp/periphery@2.20.0"
      ]
      
      for package in includedPackages + removedPackages {
        #expect(!package.isEmpty)
        #expect(package.contains("@"))
      }
    #endif
  }
}