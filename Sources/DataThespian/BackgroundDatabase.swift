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

  public import Foundation

  public import SwiftData
  import SwiftUI

  public final class BackgroundDatabase: Database {
    public func delete(_ modelType: (some PersistentModel).Type, withID id: PersistentIdentifier)
      async -> Bool
    { await self.database.delete(modelType, withID: id) }

    public func delete(where predicate: Predicate<some PersistentModel>?) async throws {
      try await self.database.delete(where: predicate)
    }

    public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel) async
      -> PersistentIdentifier
    { await self.database.insert(closuer) }

    public func fetch<T, U>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
      with closure: @escaping @Sendable ([T]) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      try await self.database.fetch(selectDescriptor, with: closure)
    }
    
    public func fetch<each T: PersistentModel, U: Sendable>(
      _ selectDescriptor: @escaping @Sendable () -> (repeat FetchDescriptor<each T>),
      with closure: @escaping @Sendable (repeat ([each T])) throws -> U
    ) async throws -> U where  U: Sendable {
      try await self.database.fetch(selectDescriptor, with: closure)
    }

    public func get<T, U>(
      for objectID: PersistentIdentifier,
      with closure: @escaping @Sendable (T?) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      try await self.database.get(for: objectID, with: closure)
    }
    public func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
      _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
      _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
      with closure: @escaping @Sendable ([T], [U]) throws -> V
    ) async throws -> V {
      try await self.database.fetch(selectDescriptorA, selectDescriptorB, with: closure)
    }

    private actor DatabaseContainer {
      private let factory: @Sendable () -> any Database
      private var wrappedTask: Task<any Database, Never>?

      // swiftlint:disable:next strict_fileprivate
      fileprivate init(factory: @escaping @Sendable () -> any Database) { self.factory = factory }

      // swiftlint:disable:next strict_fileprivate
      fileprivate var database: any Database {
        get async {
          if let wrappedTask { return await wrappedTask.value }
          let task = Task { factory() }
          self.wrappedTask = task
          return await task.value
        }
      }
    }

    private let container: DatabaseContainer

    private var database: any Database { get async { await container.database } }

    public convenience init(modelContainer: ModelContainer) {
      self.init {
        assert(isMainThread: false)
        return ModelActorDatabase(modelContainer: modelContainer)
      }
    }

    internal init(_ factory: @Sendable @escaping () -> any Database) {
      self.container = .init(factory: factory)
    }

    public func transaction(_ block: @escaping @Sendable (ModelContext) throws -> Void) async throws
    {
      assert(isMainThread: false)
      try await self.database.transaction(block)
    }
  }
#endif
