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

### Setting up Database

```swift
var body: some Scene {
  WindowGroup {
    RootView()
  }.database(ModelActorDatabase(modelContainer: ...))
}
```

and then reference it in our SwiftUI View:

```swift
@Environment(\.database) private var database
```

#### Using with ModelContext

If you are familiar with Core Data, you probably know that you should use a single `NSManagedObjectContext` throughout your app. The issue here is that our initializer for `ModelActorDatabase` will be called each time the SwiftUI View is redraw. So if we look at the expanded `@ModelActor` Macro for our `ModelActorDatabase`, we see that a new `ModelContext` (SwiftData wrapper or abstraction, etc.  of `NSManagedObjectContext`) is created each time:

```swift
public init(modelContainer: SwiftData.ModelContainer) {
    let modelContext = ModelContext(modelContainer)
    self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = modelContainer
}
```

This means if we pass SwiftData models throughout our app, we will be running our models through a variety of `ModelContext` objects which will result in a crash. The best approach to this is create a singleton for the `Database` and `ModelContainer` which ensures it to be shared across the `.environment` and application:

```swift
 public struct SharedDatabase {
  public static let shared: SharedDatabase = .init()

  public let schemas: [any PersistentModel.Type]
  public let modelContainer: ModelContainer
  public let database: any Database

  private init(
    schemas: [any PersistentModel.Type] = .all,
    modelContainer: ModelContainer? = nil,
    database: (any Database)? = nil
  ) {
    self.schemas = schemas
    let modelContainer = modelContainer ?? .forTypes(schemas)
    self.modelContainer = modelContainer
    self.database = database ?? ModelActorDatabase(modelContainer: modelContainer)
  }
}
```

Then in our SwiftUI code, we call:

```swift
var body: some Scene {
  WindowGroup {
    RootView()
  }
  .database(SharedDatabase.shared.database)
  /* if we wish to continue using @Query
  .modelContainer(SharedDatabase.shared.modelContainer)
  */
}
```

### Making Queries



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
