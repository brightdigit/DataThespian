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

  public func fetch<T, U>(
    _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
    with closure: @escaping @Sendable ([T]) throws -> U
  ) async throws -> U where T: PersistentModel, U: Sendable {
    try await self.database.fetch(selectDescriptor, with: closure)
  }

  public func get<T, U>(for objectID: PersistentIdentifier, with closure: @escaping @Sendable (T?) throws -> U) async throws -> U where T: PersistentModel, U: Sendable {
    try await self.database.get(for: objectID, with: closure)
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

  public convenience init(modelContainer: ModelContainer) {
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

  extension BackgroundDatabase {
//    public func obsoleteDelete(where predicate: Predicate<some PersistentModel & Sendable>?) async throws {
//      assert(isMainThread: false)
//      return try await self.database.obsoleteDelete(predicate)
//    }

    public func obsoleteFetch<T>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>
    ) async throws -> [T] where T: Sendable, T: PersistentModel {
      assert(isMainThread: false)
      return try await self.database.obsoleteFetch(selectDescriptor)
    }

    public func obsoleteDelete(_ model: some PersistentModel & Sendable) async {
      assert(isMainThread: false)
      return await self.database.obsoleteDelete(model)
    }

    public func obsoleteInsert(_ model: some PersistentModel & Sendable) async {
      assert(isMainThread: false)
      return await self.database.obsoleteInsert(model)
    }

    public func obsoleteSave() async throws {
      assert(isMainThread: false)
      return try await self.database.obsoleteSave()
    }

    public func obsoleteExistingModel<T>(
      for objectID: PersistentIdentifier
    ) async throws -> T? where T: Sendable, T: PersistentModel {
      assert(isMainThread: false)
      return try await self.database.obsoleteExistingModel(for: objectID)
    }
  }
#endif
