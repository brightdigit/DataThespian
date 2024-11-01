////
////  Database+Extras.swift
////  DataThespian
////
////  Created by Leo Dion.
////  Copyright © 2024 BrightDigit.
////
////  Permission is hereby granted, free of charge, to any person
////  obtaining a copy of this software and associated documentation
////  files (the “Software”), to deal in the Software without
////  restriction, including without limitation the rights to use,
////  copy, modify, merge, publish, distribute, sublicense, and/or
////  sell copies of the Software, and to permit persons to whom the
////  Software is furnished to do so, subject to the following
////  conditions:
////
////  The above copyright notice and this permission notice shall be
////  included in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
////  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
////  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
////  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
////  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
////  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
////  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
////  OTHER DEALINGS IN THE SOFTWARE.
////
//
#if canImport(SwiftData)
  public import Foundation
  public import SwiftData

  extension Database {
//    @available(*, unavailable)
//    public func with<PersistentModelType: PersistentModel, U: Sendable>(
//      _ id: Model<PersistentModelType>,
//      _ closure: @escaping @Sendable (PersistentModelType) throws -> U
//    ) async rethrows -> U {
//      try await self.get(for: id.persistentIdentifier) { (model: PersistentModelType?) -> U in
//        guard let model else {
//          throw Model<PersistentModelType>.NotFoundError(
//            persistentIdentifier: id.persistentIdentifier
//          )
//        }
//        return try closure(model)
//      }
//    }
//
//    @available(*, deprecated)
//    public func first<T: PersistentModel>(_ selectPredicate: Predicate<T>) async throws -> Model<T>?
//    {
//      try await self.first(selectPredicate, with: Model.ifMap)
//    }
//
//    @available(*, deprecated)
//    public func first<T: PersistentModel, U: Sendable>(
//      _ selectPredicate: Predicate<T>, with closure: @escaping @Sendable (T?) throws -> U
//    ) async throws -> U {
//      try await self.fetch {
//        .init(predicate: selectPredicate, fetchLimit: 1)
//      } with: { models in
//        try closure(models.first)
//      }
//    }
//
//    @available(*, deprecated)
//    public func delete<T: PersistentModel>(model _: T.Type, where predicate: Predicate<T>? = nil)
//      async throws
//    { try await self.delete(where: predicate) }
//
//    @available(*, deprecated)
//    public func delete<T: PersistentModel>(_ model: Model<T>) async {
//      await self.delete(T.self, withID: model.persistentIdentifier)
//    }
//
    public func deleteAll(of types: [any PersistentModel.Type]) async throws {
      try await self.transaction { context in for type in types { try context.delete(model: type) }
      }
    }
//
//    @available(*, deprecated)
//    public func fetch<T: PersistentModel, U: Sendable>(
//      _: T.Type, with closure: @escaping @Sendable ([T]) throws -> U
//    ) async throws -> U {
//      try await self.fetch {
//        FetchDescriptor<T>()
//      } with: { models in
//        try closure(models)
//      }
//    }
//
//    @available(*, deprecated)
//    public func fetch<T: PersistentModel>(_: T.Type) async throws -> [Model<T>] {
//      try await self.fetch(T.self) { models in models.map(Model.init) }
//    }
//
//    @available(*, deprecated)
//    public func fetch<T: PersistentModel>(
//      _: T.Type, _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>
//    ) async throws -> [Model<T>] {
//      await self.fetch(selectDescriptor) { models in models.map(Model.init) }
//    }
//
//    @available(*, deprecated)
//    public func fetch<T, U: Sendable>(
//      of _: T.Type,
//      for objectIDs: [PersistentIdentifier],
//      with closure: @escaping @Sendable (T) throws -> U
//    ) async throws -> [U] where T: PersistentModel {
//      try await withThrowingTaskGroup(of: U?.self, returning: [U].self) { group in
//        for id in objectIDs {
//          group.addTask { try await self.get(for: id) { model in try model.map(closure) } }
//        }
//
//        return try await group.reduce(into: []) { partialResult, item in
//          if let item { partialResult.append(item) }
//        }
//      }
//    }
//
//    @available(*, deprecated)
//    public func get<T, U: Sendable>(
//      of _: T.Type,
//      for objectID: PersistentIdentifier,
//      with closure: @escaping @Sendable (T?) throws -> U
//    ) async throws -> U where T: PersistentModel {
//      try await self.get(for: objectID) { model in try closure(model) }
//    }
  }
#endif
