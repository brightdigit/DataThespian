//
//  Queryable+Extensions.swift
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
  public import SwiftData

  extension Queryable {
    @discardableResult
    public func insert<PersistentModelType: PersistentModel>(
      _ closuer: @Sendable @escaping () -> PersistentModelType
    ) async -> Model<PersistentModelType> {
      await self.insert(closuer, with: Model.init)
    }

    public func getOptional<PersistentModelType>(
      for selector: Selector<PersistentModelType>.Get
    ) async -> Model<PersistentModelType>? {
      await self.getOptional(for: selector) { persistentModel in
        persistentModel.flatMap(Model.init)
      }
    }

    public func fetch<PersistentModelType>(
      for selector: Selector<PersistentModelType>.List
    ) async -> [Model<PersistentModelType>] {
      await self.fetch(for: selector) { persistentModels in
        persistentModels.map(Model.init)
      }
    }

    public func get<PersistentModelType>(
      for selector: Selector<PersistentModelType>.Get
    ) async throws -> Model<PersistentModelType> {
      try await self.getOptional(for: selector) { persistentModel in
        guard let persistentModel else {
          throw QueryError<PersistentModelType>.itemNotFound(selector)
        }
        return Model(persistentModel)
      }
    }

    public func get<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async throws -> U {
      try await self.getOptional(for: selector) { persistentModel in
        guard let persistentModel else {
          throw QueryError<PersistentModelType>.itemNotFound(selector)
        }
        return try closure(persistentModel)
      }
    }

    public func update<PersistentModelType>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType) throws -> Void
    ) async throws {
      try await self.get(for: selector, with: closure)
    }

    public func update<PersistentModelType>(
      for selector: Selector<PersistentModelType>.List,
      with closure: @escaping @Sendable ([PersistentModelType]) throws -> Void
    ) async throws {
      try await self.fetch(for: selector, with: closure)
    }

    public func insertIf<PersistentModelType>(
      _ model: @Sendable @escaping () -> PersistentModelType,
      notExist selector: @Sendable @escaping (PersistentModelType) ->
        Selector<PersistentModelType>.Get
    ) async -> Model<PersistentModelType> {
      let persistentModel = model()
      let selector = selector(persistentModel)
      let modelOptional = await self.getOptional(for: selector)

      if let modelOptional {
        return modelOptional
      } else {
        return await self.insert(model)
      }
    }

    public func insertIf<PersistentModelType, U: Sendable>(
      _ model: @Sendable @escaping () -> PersistentModelType,
      notExist selector: @Sendable @escaping (PersistentModelType) ->
        Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async throws -> U {
      let model = await self.insertIf(model, notExist: selector)
      return try await self.get(for: .model(model), with: closure)
    }
  }

  extension Queryable {
    public func deleteModels<PersistentModelType>(_ models: [Model<PersistentModelType>])
      async throws
    {
      try await withThrowingTaskGroup(
        of: Void.self,
        body: { group in
          for model in models {
            group.addTask {
              try await self.delete(.model(model))
            }
          }
          try await group.waitForAll()
        }
      )
    }
  }
#endif
