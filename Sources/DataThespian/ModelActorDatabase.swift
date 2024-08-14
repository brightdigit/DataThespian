//
// ModelActorDatabase.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)




  public import Foundation

  public import SwiftData

  @ModelActor
  public actor ModelActorDatabase: Database, Loggable {
    public func delete<T: PersistentModel>(_: T.Type, withID id: PersistentIdentifier) async -> Bool {
      guard let model: T = self.modelContext.registeredModel(for: id) else {
        return false
      }
      
      self.modelContext.delete(model)

      return true
    }

    public func delete<T>(where predicate: Predicate<T>?) async throws where T: PersistentModel {
      try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel) async -> PersistentIdentifier {
      let model = closuer()
      self.modelContext.insert(model)
      return model.persistentModelID
    }

    public func fetch<T, U>(_ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>, with closure: @escaping @Sendable ([T]) throws -> U) async throws -> U where T: PersistentModel, U: Sendable {
      let models = try self.modelContext.fetch(selectDescriptor())
      return try closure(models)
    }

    public func fetch<T, U>(for objectID: PersistentIdentifier, with closure: @escaping @Sendable (T?) throws -> U) async throws -> U? where T: PersistentModel, U: Sendable {
      let model: T? = try self.modelContext.existingModel(for: objectID)
      return try closure(model)
    }

    public static var loggingCategory: ThespianLogging.Category {
      .data
    }

    public func transaction(_ block: @escaping @Sendable (ModelContext) throws -> Void) async throws {
      assert(isMainThread: false)

      try self.modelContext.transaction {
        assert(isMainThread: false)
        try block(modelContext)
      }
    }
  }

  extension ModelActorDatabase {
    public func obsoleteDelete(_ model: some PersistentModel & Sendable) async {
      assert(isMainThread: false)
      assert(model.modelContext == self.modelContext || model.modelContext == nil)
      guard model.modelContext == self.modelContext else {
        return
      }

      Self.logger.debug("Delete begun: \(type(of: model).self)")
      self.modelContext.delete(model)
    }

    public func obsoleteInsert(_ model: some PersistentModel & Sendable) async {
      assert(isMainThread: false)
      assert(model.modelContext == self.modelContext || model.modelContext == nil)
      guard model.modelContext == self.modelContext || model.modelContext == nil else {
        return
      }
      Self.logger.debug("Insert begun: \(type(of: model).self)")
      self.modelContext.insert(model)
    }

    public func obsoleteDelete<T: PersistentModel & Sendable>(
      where predicate: Predicate<T>?
    ) async throws {
      assert(isMainThread: false)

      Self.logger.debug("Delete begun: \(T.self)")
      try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func obsoleteSave() async throws {
      assert(isMainThread: false)
      Self.logger.debug("Save begun")
      try self.modelContext.save()
    }

    public func obsoleteFetch<T>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>
    ) async throws -> [T] where T: Sendable, T: PersistentModel {
      assert(isMainThread: false)
      Self.logger.debug("Fetch begun: \(T.self)")
      return try self.modelContext.fetch(selectDescriptor())
    }

    public func fetch<T>(
      _ selectDescriptor: FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable {
      assert(isMainThread: false)
      Self.logger.debug("Fetch begun: \(T.self)")
      return try self.modelContext.fetch(selectDescriptor)
    }

    public func obsoleteExistingModel<T>(
      for objectID: PersistentIdentifier
    ) async throws -> T? where T: Sendable, T: PersistentModel {
      try self.modelContext.existingModel(for: objectID)
    }
  }

#endif
