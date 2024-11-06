//
//  ModelContext+Queryable.swift
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
  /// Extends the `ModelContext` class with additional methods for querying and managing persistent models.
  extension ModelContext {
    /// Inserts a new persistent model and performs a closure on it.
    ///
    /// - Parameters:
    ///   - closuer: A closure that creates a new instance of the persistent model.
    ///   - closure: A closure that performs an operation on the newly inserted persistent model.
    /// - Returns: The result of the `closure` parameter.
    public func insert<PersistentModelType: PersistentModel, U: Sendable>(
      _ closuer: @Sendable @escaping () -> PersistentModelType,
      with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) rethrows -> U {
      let persistentModel = closuer()
      self.insert(persistentModel)
      return try closure(persistentModel)
    }

    /// Retrieves an optional persistent model based on a selector.
    ///
    /// - Parameter selector: A selector that specifies the criteria for retrieving the persistent model.
    /// - Returns: An optional persistent model that matches the selector criteria.
    /// - Throws: A `SwiftData` error.
    public func getOptional<PersistentModelType>(for selector: Selector<PersistentModelType>.Get)
      throws -> PersistentModelType?
    {
      let persistentModel: PersistentModelType?
      switch selector {
      case .model(let model):
        persistentModel = try self.getOptional(model)
      case .predicate(let predicate):
        persistentModel = try self.first(where: predicate)
      }
      return persistentModel
    }

    /// Retrieves an optional persistent model based on a selector and performs a closure on it.
    ///
    /// - Parameters:
    ///   - selector: A selector that specifies the criteria for retrieving the persistent model.
    ///   - closure: A closure that performs an operation on the retrieved persistent model.
    /// - Returns: The result of the `closure` parameter.
    /// - Throws: A `SwiftData` error.
    public func getOptional<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType?) throws -> U
    ) throws -> U {
      let persistentModel: PersistentModelType?
      switch selector {
      case .model(let model):
        persistentModel = try self.getOptional(model)
      case .predicate(let predicate):
        persistentModel = try self.first(where: predicate)
      }
      return try closure(persistentModel)
    }

    /// Retrieves a list of persistent models based on a selector and performs a closure on it.
    ///
    /// - Parameters:
    ///   - selector: A selector that specifies the criteria for retrieving the list of persistent models.
    ///   - closure: A closure that performs an operation on the retrieved list of persistent models.
    /// - Returns: The result of the `closure` parameter.
    /// - Throws: A `SwiftData` error.
    public func fetch<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.List,
      with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
    ) throws -> U {
      let persistentModels: [PersistentModelType]
      switch selector {
      case .descriptor(let descriptor):
        persistentModels = try self.fetch(descriptor)
      }
      return try closure(persistentModels)
    }

    /// Deletes persistent models based on a selector.
    ///
    /// - Parameter selector: A selector that specifies the criteria for deleting the persistent models.
    /// - Throws: A `SwiftData` error.
    public func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) throws
    {
      switch selector {
      case .all:
        try self.delete(model: PersistentModelType.self)
      case .model(let model):
        if let persistentModel = try self.getOptional(model) {
          self.delete(persistentModel)
        }
      case .predicate(let predicate):
        try self.delete(model: PersistentModelType.self, where: predicate)
      }
    }
  }
#endif
