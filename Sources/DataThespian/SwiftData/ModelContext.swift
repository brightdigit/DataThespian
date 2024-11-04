//
//  ModelContext.swift
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
  import Foundation
  public import SwiftData

  /// An extension to the `ModelContext` class that provides additional functionality using ``Model``.
  extension ModelContext {
    /// Retrieves an optional persistent model of the specified type with the given persistent identifier.
    ///
    /// - Parameter model: The model for which to retrieve the persistent model.
    /// - Returns: An optional instance of the specified persistent model,
    /// or `nil` if the model was not found.
    public func getOptional<T>(_ model: Model<T>) throws -> T?
    where T: PersistentModel {
      try self.persistentModel(withID: model.persistentIdentifier)
    }

    /// Retrieves a persistent model of the specified type with the given persistent identifier.
    ///
    /// - Parameter objectID: The persistent identifier of the model to retrieve.
    /// - Returns: An optional instance of the specified persistent model,
    /// or `nil` if the model was not found.
    private func persistentModel<T>(withID objectID: PersistentIdentifier) throws -> T?
    where T: PersistentModel {
      if let registered: T = registeredModel(for: objectID) {
        return registered
      }
      if let notRegistered: T = model(for: objectID) as? T {
        return notRegistered
      }
      

      let fetchDescriptor = FetchDescriptor<T>(
        predicate: #Predicate { $0.persistentModelID == objectID },
        fetchLimit: 1
      )

      return try fetch(fetchDescriptor).first
    }
  }
#endif
