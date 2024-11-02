//
//  ModelContext+Extension.swift
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
  /// Extension to `ModelContext` to provide additional functionality for managing persistent models.
  extension ModelContext {
    /// Inserts a new persistent model into the context.
    /// - Parameter closuer: A closure that creates a new instance of the `PersistentModel`.
    /// - Returns: A `Model` instance representing the newly inserted model.
    public func insert<T: PersistentModel>(_ closuer: @escaping @Sendable () -> T) -> Model<T> {
      let model = closuer()
      self.insert(model)
      return .init(model)
    }

    /// Fetches an array of persistent models based on the provided selectors.
    /// - Parameter selectors: An array of `Selector<PersistentModelType>.Get` instances
    /// to fetch the models.
    /// - Returns: An array of `PersistentModelType` instances.
    public func fetch<PersistentModelType>(
      for selectors: [Selector<PersistentModelType>.Get]
    ) throws -> [PersistentModelType] {
      try selectors
        .map {
          try self.getOptional(for: $0)
        }
        .compactMap { $0 }
    }

    /// Retrieves a persistent model from the context.
    /// - Parameter model: A `Model<T>` instance representing the persistent model to fetch.
    /// - Returns: The `T` instance of the persistent model.
    /// - Throws: `QueryError.itemNotFound` if the model is not found in the context.
    public func get<T>(_ model: Model<T>) throws -> T
    where T: PersistentModel {
      guard let item = try self.getOptional(model) else {
        throw QueryError.itemNotFound(.model(model))
      }
      return item
    }

    /// Deletes persistent models based on the provided selectors.
    /// - Parameter selectors: An array of `Selector<PersistentModelType>.Delete` instances
    /// to delete the models.
    public func delete<PersistentModelType>(
      _ selectors: [Selector<PersistentModelType>.Delete]
    ) throws {
      for selector in selectors {
        try self.delete(selector)
      }
    }

    /// Retrieves the first persistent model that matches the provided predicate.
    /// - Parameter predicate: An optional `Predicate<PersistentModelType>` instance to filter the results.
    /// - Returns: The first `PersistentModelType` instance that matches the predicate,
    /// or `nil` if no match is found.
    public func first<PersistentModelType: PersistentModel>(
      where predicate: Predicate<PersistentModelType>? = nil
    ) throws -> PersistentModelType? {
      try self.fetch(FetchDescriptor(predicate: predicate, fetchLimit: 1)).first
    }
  }
#endif
