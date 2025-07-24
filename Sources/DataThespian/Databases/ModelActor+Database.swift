//
//  ModelActor+Database.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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
  import os.log
  public import SwiftData

  extension ModelActor where Self: Database {
    /// A Boolean value indicating whether the current thread is the background thread.
    public static var assertIsBackground: Bool { false }

    /// Executes a closure within the context of the model.
    ///
    /// - Parameter closure: The closure to execute within the model context.
    /// - Returns: The result of the closure execution.
    public func withModelContext<T: Sendable>(
      _ closure: @Sendable @escaping (ModelContext) throws -> T
    ) async rethrows -> T {
      assert(isMainThread: true, if: Self.assertIsBackground)
      let modelContext = self.modelContext
      return try closure(modelContext)
    }
    /// Retrieves an optional persistent model from the data store and returns a transformed result.
    /// - Parameters:
    ///   - selector: A `Selector<PersistentModelType>.Get` instance
    ///   that defines the criteria for retrieving the persistent model.
    ///   - closure: A closure that performs some operation on
    ///   the retrieved `PersistentModelType` instance (or `nil`)
    ///   and returns a transformed result of type `U`.
    /// - Returns: The transformed result of type `U`.
    public func getOptional<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType?) throws -> U
    ) async rethrows -> U {
      guard case .model(let model) = selector else {
        return try await self.withModelContext {
          try $0.getOptional(for: selector, with: closure)
        }
      }

      return try closure(self[model.persistentIdentifier, as: PersistentModelType.self]?.flatOptional())
    }

    /// Fetches an array of models matching the given list selector
    /// - Parameter selector: A selector defining the query criteria for retrieving multiple models
    /// - Returns: An array of wrapped Model instances matching the selector criteria
    public func fetch<PersistentModelType>(for selector: Selector<PersistentModelType>.List)
      async -> [Model<PersistentModelType>] where PersistentModelType: PersistentModel
    {
      let fetchedIdentifiers: [Model<PersistentModelType>]

      guard case .descriptor(let descriptor) = selector else {
        fatalError("Invalid selector: \(selector)")
      }

      do {
        fetchedIdentifiers = try await self.withModelContext { modelContext in
          try modelContext.fetchIdentifiers(descriptor).map(
            Model<PersistentModelType>.init(persistentIdentifier:)
          )
        }
      } catch {
        os_log(.error, "Failed to fetch identifiers: %{public}@", error.localizedDescription)
        return []
      }

      return fetchedIdentifiers
    }
  }
#endif
