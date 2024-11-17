# ``DataThespian``

A thread-safe implementation of SwiftData. 

## Overview

DataThespian combines the power of Actors, SwiftData, and ModelActors to create an optimized and easy-to-use APIs for developers.

### Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

### Installation

To integrate **DataThespian** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(
        url: "https://github.com/brightdigit/DataThespian.git", from: "1.0.0"
    )
  ],
  targets: [
      .target(
          name: "YourApps",
          dependencies: [
            .product(
                name: "DataThespian", 
                package: "DataThespian"
            ), ...
          ]),
      ...
  ]
)
```

## Topics

### Database

- ``Database``
- ``BackgroundDatabase``
- ``ModelActorDatabase``

### Querying

- ``Queryable``
- ``QueryError``
- ``Selector``
- ``Model``
- ``Unique``
- ``UniqueKey``
- ``UniqueKeys``
- ``UniqueKeyPath``

### Monitoring

- ``DataMonitor``
- ``DataAgent``
- ``DatabaseChangeSet``
- ``DatabaseMonitoring``
- ``AgentRegister``
- ``ManagedObjectMetadata``
- ``DatabaseChangePublicist``
- ``DatabaseChangeType``

### Synchronization

- ``CollectionSynchronizer``
- ``ModelDifferenceSynchronizer``
- ``ModelSynchronizer``
- ``SynchronizationDifference``
- ``CollectionDifference``

### Logging

- ``ThespianLogging``
