//
// Database.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)

    public import Foundation

    public import SwiftData


public struct ModelID<T: PersistentModel>: Sendable {
  let persistentIdentifier: PersistentIdentifier

  enum Error: Swift.Error {
    case notFound(PersistentIdentifier)
  }
}

extension ModelID where T: PersistentModel {
  public init(_ model: T) {
    self.init(persistentIdentifier: model.persistentModelID)
  }

  fileprivate static func ifMap(_ model: T?) -> ModelID? {
    model.map(self.init)
  }
}


public protocol Database: Sendable, ObsoleteDatabase {
  @discardableResult
  func delete<T: PersistentModel>(_ modelType: T.Type, withID id: PersistentIdentifier) async -> Bool

  func delete<T: PersistentModel>(
    where predicate: Predicate<T>?
  ) async throws

  func insert(_ closuer: @Sendable @escaping () -> some PersistentModel) async -> PersistentIdentifier

  func fetch<T, U: Sendable>(
    _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
    with closure: @escaping @Sendable ([T]) throws -> U
  ) async throws -> U

  func get<T, U: Sendable>(
    for objectID: PersistentIdentifier,
    with closure: @escaping @Sendable (T?) throws -> U
  ) async throws -> U where T: PersistentModel

  func transaction(_ block: @Sendable @escaping (ModelContext) throws -> Void) async throws
}

extension Database {
  public func insert<PersistentModelType: PersistentModel>(_ closuer: @Sendable @escaping () -> PersistentModelType) async -> ModelID<PersistentModelType> {
    let id: PersistentIdentifier = await self.insert(closuer)
    return .init(persistentIdentifier: id)
  }

  public func with<PersistentModelType: PersistentModel, U: Sendable>(
    _ id: ModelID<PersistentModelType>,
    _ closure: @escaping @Sendable (PersistentModelType) throws -> U
  ) async throws -> U {
    try await self.get(for: id.persistentIdentifier) { (model: PersistentModelType?) -> U in
      guard let model else {
        throw ModelID<PersistentModelType>.Error.notFound(id.persistentIdentifier)
      }
      return try closure(model)
    }
  }

  public func first<T: PersistentModel>(
    _ selectPredicate: Predicate<T>
  ) async throws -> ModelID<T>? {
    try await self.first(selectPredicate, with: ModelID.ifMap)
  }

  public func first<T: PersistentModel, U: Sendable>(
    _ selectPredicate: Predicate<T>,
    with closure: @escaping @Sendable (T?) throws -> U
  ) async throws -> U {
    try await self.fetch {
      .init(predicate: selectPredicate, fetchLimit: 1)
    } with: { models in
      try closure(models.first)
    }
  }

  public func first<T: PersistentModel, U: Sendable>(
    fetchWith selectPredicate: Predicate<T>,
    otherwiseInsertBy insert: @Sendable @escaping () -> T,
    with closure: @escaping @Sendable (T) throws -> U
  ) async throws -> U {
    let value = try await self.fetch {
      .init(predicate: selectPredicate, fetchLimit: 1)
    } with: { models in
      try models.first.map(closure)
    }

    if let value {
      return value
    }

    let inserted: ModelID = await self.insert(insert)

    return try await self.with(inserted, closure)
  }

  public func delete<T: PersistentModel>(
    model _: T.Type,
    where predicate: Predicate<T>? = nil
  ) async throws {
    try await self.delete(where: predicate)
  }

  public func delete<T: PersistentModel>(_ model: ModelID<T>) async {
    await self.delete(T.self, withID: model.persistentIdentifier)
  }

  public func deleteAll(of types: [any PersistentModel.Type]) async throws {
    try await self.transaction { context in
      try types.forEach {
        try context.delete(model: $0)
      }
    }
  }

  public func fetch<T: PersistentModel, U: Sendable>(_: T.Type, with closure: @escaping @Sendable ([T]) throws -> U) async throws -> U {
    try await self.fetch {
      FetchDescriptor<T>()
    } with: { models in
      try closure(models)
    }
  }

  public func fetch<T: PersistentModel>(_: T.Type) async throws -> [ModelID<T>] {
    try await self.fetch(T.self) { models in
      models.map(ModelID.init)
    }
  }

  public func fetch<T, U: Sendable>(
    of _: T.Type,
    for objectIDs: [PersistentIdentifier],
    with closure: @escaping @Sendable (T) throws -> U
  ) async throws -> [U] where T: PersistentModel {
    try await withThrowingTaskGroup(of: U?.self, returning: [U].self) { group in
      for id in objectIDs {
        group.addTask {
          try await self.get(for: id) { model in
            try model.map(closure)
          }
        }
      }

      return try await group.reduce(into: []) { partialResult, item in
        if let item {
          partialResult.append(item)
        }
      }
    }
  }

  public func get<T, U: Sendable>(
    of _: T.Type,
    for objectID: PersistentIdentifier,
    with closure: @escaping @Sendable (T?) throws -> U
  ) async throws -> U where T: PersistentModel {
    try await self.get(for: objectID) { model in
      try closure(model)
    }
  }
}
//    public extension Database {
//        static var loggingCategory: ThespianLogging.Category {
//            .data
//        }
//    }

#endif
