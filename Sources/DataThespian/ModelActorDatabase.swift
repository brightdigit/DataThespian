//
//  ModelActorDatabase.swift
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

public enum DeleteSelector<PersistentModelType : PersistentModel> : Sendable {
  case persistentModelID(PersistentIdentifier)
  case predicate(Predicate<PersistentModelType>)
  case all
}

  public actor ModelActorDatabase: Database, Loggable {
    public func delete<T: PersistentModel>(_: T.Type, withID id: PersistentIdentifier) async -> Bool
    {
      guard let model: T = self.modelContext.registeredModel(for: id) else { return false }
      self.modelContext.delete(model)
      return true
    }

    public func delete<T>(where predicate: Predicate<T>?) async throws where T: PersistentModel {
      try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel) async
      -> PersistentIdentifier
    {
      let model = closuer()
      self.modelContext.insert(model)
      return model.persistentModelID
    }
    
    public func withModelContext<T: Sendable>(_ closure: @Sendable (ModelContext) throws -> T) async rethrows -> T {
      let modelContext = self.modelContext
      return try closure(modelContext)
    }

    public func fetch<T, U>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
      with closure: @escaping @Sendable ([T]) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      let models = try self.modelContext.fetch(selectDescriptor())
      return try closure(models)
    }
    public func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
      _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
      _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
      with closure: @escaping @Sendable ([T], [U]) throws -> V
    ) async throws -> V {
      let a = try self.modelContext.fetch(selectDescriptorA())
      let b = try self.modelContext.fetch(selectDescriptorB())
      return try closure(a, b)
    }

    public func get<T, U>(
      for objectID: PersistentIdentifier,
      with closure: @escaping @Sendable (T?) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      let model: T? = try self.modelContext.existingModel(for: objectID)
      return try closure(model)
    }
    public static var loggingCategory: ThespianLogging.Category { .data }

    public func transaction(_ block: @escaping @Sendable (ModelContext) throws -> Void) async throws
    {
      assert(isMainThread: false)

      try self.modelContext.transaction {
        assert(isMainThread: false)
        try block(modelContext)
      }
    }
    public func save() throws {
      assert(isMainThread: false)
      try self.modelContext.save()
    }

    public nonisolated let modelExecutor: any SwiftData.ModelExecutor

    public nonisolated let modelContainer: SwiftData.ModelContainer

    public init(modelContainer: SwiftData.ModelContainer, autosaveEnabled: Bool = false) {
      let modelContext = ModelContext(modelContainer)
      modelContext.autosaveEnabled = autosaveEnabled
      let modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
      self.init(modelExecutor: modelExecutor, modelContainer: modelContainer)
    }
    private init(modelExecutor: any ModelExecutor, modelContainer: ModelContainer) {
      self.modelExecutor = modelExecutor
      self.modelContainer = modelContainer
    }
  }

  extension ModelActorDatabase: SwiftData.ModelActor {}

#endif
