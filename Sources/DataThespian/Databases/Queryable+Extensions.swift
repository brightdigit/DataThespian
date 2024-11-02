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
    /// Inserts a new persistent model into the database
    /// - Parameter closure: A closure that creates and returns a new persistent model
    /// - Returns: A wrapped Model instance containing the inserted persistent model
    @discardableResult
    public func insert<PersistentModelType: PersistentModel>(
      _ closure: @Sendable @escaping () -> PersistentModelType
    ) async -> Model<PersistentModelType> {
      await self.insert(closure, with: Model.init)
    }

    /// Retrieves an optional model matching the given selector
    /// - Parameter selector: A selector defining the query criteria for retrieving the model
    /// - Returns: An optional wrapped Model instance if found, nil otherwise
    public func getOptional<PersistentModelType>(
      for selector: Selector<PersistentModelType>.Get
    ) async -> Model<PersistentModelType>? {
      await self.getOptional(for: selector) { persistentModel in
        persistentModel.flatMap(Model.init)
      }
    }

    /// Fetches an array of models matching the given list selector
    /// - Parameter selector: A selector defining the query criteria for retrieving multiple models
    /// - Returns: An array of wrapped Model instances matching the selector criteria
    public func fetch<PersistentModelType>(
      for selector: Selector<PersistentModelType>.List
    ) async -> [Model<PersistentModelType>] {
      await self.fetch(for: selector) { persistentModels in
        persistentModels.map(Model.init)
      }
    }

    /// Fetches and transforms multiple models using an array of selectors
    /// - Parameters:
    ///   - selectors: An array of selectors to fetch models
    ///   - closure: A transformation closure to apply to each fetched model
    /// - Returns: An array of transformed results
    /// - Throws: Rethrows any errors from the transformation closure
    public func fetch<PersistentModelType, U: Sendable>(
      for selectors: [Selector<PersistentModelType>.Get],
      with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async rethrows -> [U] {
      try await withThrowingTaskGroup(
        of: Optional<U>.self,
        returning: [U].self,
        body: { group in
          for selector in selectors {
            group.addTask {
              try await self.getOptional(for: selector) { persistentModel in
                guard let persistentModel else {
                  return Optional<U>.none
                }
                return try closure(persistentModel)
              }
            }
          }
          return try await group.reduce(into: [U]()) { partialResult, result in
            if let result {
              partialResult.append(result)
            }
          }
        }
      )
    }

    /// Retrieves a required model matching the given selector
    /// - Parameter selector: A selector defining the query criteria
    /// - Returns: A wrapped Model instance
    /// - Throws: QueryError.itemNotFound if the model doesn't exist
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

    /// Retrieves and transforms a required model matching the given selector
    /// - Parameters:
    ///   - selector: A selector defining the query criteria
    ///   - closure: A transformation closure to apply to the fetched model
    /// - Returns: The transformed result
    /// - Throws: QueryError.itemNotFound if the model doesn't exist
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

    /// Updates a single model matching the given selector
    /// - Parameters:
    ///   - selector: A selector defining the model to update
    ///   - closure: A closure that performs the update operation
    /// - Throws: QueryError.itemNotFound if the model doesn't exist
    public func update<PersistentModelType>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType) throws -> Void
    ) async throws {
      try await self.get(for: selector, with: closure)
    }

    /// Updates multiple models matching the given list selector
    /// - Parameters:
    ///   - selector: A selector defining the models to update
    ///   - closure: A closure that performs the update operation on the array of models
    /// - Throws: Rethrows any errors from the update closure
    public func update<PersistentModelType>(
      for selector: Selector<PersistentModelType>.List,
      with closure: @escaping @Sendable ([PersistentModelType]) throws -> Void
    ) async throws {
      try await self.fetch(for: selector, with: closure)
    }

    /// Inserts a model if it doesn't already exist based on a selector
    /// - Parameters:
    ///   - model: A closure that creates the model to insert
    ///   - selector: A closure that creates a selector from the model to check existence
    /// - Returns: Either the existing model or the newly inserted model
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

    /// Inserts a model if it doesn't exist and transforms it
    /// - Parameters:
    ///   - model: A closure that creates the model to insert
    ///   - selector: A closure that creates a selector from the model to check existence
    ///   - closure: A transformation closure to apply to the resulting model
    /// - Returns: The transformed result
    /// - Throws: Rethrows any errors from the transformation closure
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
    /// Deletes multiple models from the database
    /// - Parameter models: An array of models to delete
    /// - Throws: Rethrows any errors that occur during deletion
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
