//
//  BackgroundDatabase.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(SwiftData)
  import Foundation
  public import SwiftData

  /// Represents a background database that can be used in a concurrent environment.
  public final class BackgroundDatabase: Database {
    private actor DatabaseContainer {
      private let factory: @Sendable () -> any Database
      private var wrappedTask: Task<any Database, Never>?

      /// Initializes a `DatabaseContainer` with the given factory.
      /// - Parameter factory: A closure that creates a new database instance.
      fileprivate init(factory: @escaping @Sendable () -> any Database) {
        self.factory = factory
      }

      /// Provides access to the database instance, creating it lazily if necessary.
      fileprivate var database: any Database {
        get async {
          if let wrappedTask {
            return await wrappedTask.value
          }
          let task = Task { factory() }
          self.wrappedTask = task
          return await task.value
        }
      }
    }

    private let container: DatabaseContainer

    /// The database instance, accessed asynchronously.
    private var database: any Database {
      get async {
        await container.database
      }
    }

    public convenience init(database: @Sendable @escaping @autoclosure () -> any Database) {
      self.init(database)
    }

    /// Initializes a `BackgroundDatabase` with the given database factory.
    /// - Parameter factory: A closure that creates a new database instance.
    public init(_ factory: @Sendable @escaping () -> any Database) {
      self.container = .init(factory: factory)
    }

    /// Executes the given closure within the context of the database's model context.
    /// - Parameter closure: A closure that performs operations within the model context.
    /// - Returns: The result of the closure.
    public func withModelContext<T>(_ closure: @Sendable @escaping (ModelContext) throws -> T)
      async rethrows -> T
    {
      try await self.database.withModelContext(closure)
    }
  }

  extension BackgroundDatabase {
    /// Initializes a `BackgroundDatabase` with the given model container and
    /// optional model context closure.
    /// - Parameters:
    ///   - modelContainer: The model container to use.
    ///   - closure: An optional closure that creates a model context
    ///   from the provided model container.
    public convenience init(
      modelContainer: ModelContainer,
      modelContext closure: (@Sendable (ModelContainer) -> ModelContext)? = nil
    ) {
      let closure = closure ?? ModelContext.init
      self.init(database: ModelActorDatabase(modelContainer: modelContainer, modelContext: closure))
    }

    /// Initializes a `BackgroundDatabase` with the given model container and the default model context.
    /// - Parameter modelContainer: The model container to use.
    public convenience init(
      modelContainer: SwiftData.ModelContainer
    ) {
      self.init(
        modelContainer: modelContainer,
        modelContext: ModelContext.init
      )
    }

    /// Initializes a `BackgroundDatabase` with the given model container and model executor closure.
    /// - Parameters:
    ///   - modelContainer: The model container to use.
    ///   - closure: A closure that creates a model executor from the provided model container.
    public convenience init(
      modelContainer: SwiftData.ModelContainer,
      modelExecutor closure: @Sendable @escaping (ModelContainer) -> any ModelExecutor
    ) {
      self.init(
        database: ModelActorDatabase(
          modelContainer: modelContainer,
          modelExecutor: closure
        )
      )
    }
  }
#endif
