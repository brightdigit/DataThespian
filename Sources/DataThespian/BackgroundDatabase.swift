//
// BackgroundDatabase.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)


  public import Foundation

  public import SwiftData
  import SwiftUI

  public final class BackgroundDatabase: Database {
    public func delete(_ modelType: (some PersistentModel).Type, withID id: PersistentIdentifier) async -> Bool {
      await self.database.delete(modelType, withID: id)
    }

    public func delete(where predicate: Predicate<some PersistentModel>?) async throws {
      try await self.database.delete(where: predicate)
    }

    public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel) async -> PersistentIdentifier {
      await self.database.insert(closuer)
    }

    public func fetch<T, U>(_ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>, with closure: @escaping @Sendable ([T]) throws -> U) async throws -> U where T: PersistentModel, U: Sendable {
      try await self.database.fetch(selectDescriptor, with: closure)
    }

    public func fetch<T, U>(for objectID: PersistentIdentifier, with closure: @escaping @Sendable (T?) throws -> U) async throws -> U? where T: PersistentModel, U: Sendable {
      try await self.database.fetch(for: objectID, with: closure)
    }

    private actor DatabaseContainer {
      private let factory: @Sendable () -> any Database
      private var wrappedTask: Task<any Database, Never>?

      // swiftlint:disable:next strict_fileprivate
      fileprivate init(factory: @escaping @Sendable () -> any Database) {
        self.factory = factory
      }

      // swiftlint:disable:next strict_fileprivate
      fileprivate var database: any Database {
        get async {
          if let wrappedTask {
            return await wrappedTask.value
          }
          let task = Task {
            factory()
          }
          self.wrappedTask = task
          return await task.value
        }
      }
    }

    private let container: DatabaseContainer

    private var database: any Database {
      get async {
        await container.database
      }
    }

    package convenience init(modelContainer: ModelContainer) {
      self.init {
        assert(isMainThread: false)
        return ModelActorDatabase(modelContainer: modelContainer)
      }
    }

    internal init(_ factory: @Sendable @escaping () -> any Database) {
      self.container = .init(factory: factory)
    }

    public func transaction(_ block: @escaping @Sendable (ModelContext) throws -> Void) async throws {
      assert(isMainThread: false)
      try await self.database.transaction(block)
    }
  }

 
#endif
