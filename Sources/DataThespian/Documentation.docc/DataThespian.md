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

The best approach is to create a singleton using `SharedDatabase`:

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

Then in your SwiftUI code:

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

DataThespian uses a type-safe `Selector` enum to specify what data to query:

```swift
// Get a single item
let item = try await database.get(for: .predicate(#Predicate<Item> { 
    $0.name == "Test" 
}))

// Fetch a list with sorting
let items = await database.fetch(for: .descriptor(
    predicate: #Predicate<Item> { $0.isActive == true },
    sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)],
    fetchLimit: 10
))

// Delete matching items
try await database.delete(.predicate(#Predicate<Item> { 
    $0.timestamp < oneWeekAgo 
}))
```

### Important: Working with Temporary IDs

When inserting new models, SwiftData assigns temporary IDs that cannot be used across contexts until explicitly saved. After saving, you must re-query using a field value rather than the Model reference. Here's the safe pattern:

```swift
// Create with a known unique value
let timestamp = Date()
let newItem = await database.insert { Item(name: "Test", timestamp: timestamp) }

// Save to get permanent ID
try await database.save()

// Re-query using a unique field value
let item = try await database.getOptional(for: .predicate(#Predicate<Item> { 
    $0.timestamp == timestamp 
}))
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
