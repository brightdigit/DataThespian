//
//  Queryable.swift
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
  /// A protocol that defines a Queryable interface for interacting with a persistent data store.
  public protocol Queryable: Sendable {
    /// Saves the current state of the Queryable instance to the persistent data store.
    /// - Throws: An error that indicates why the save operation failed.
    func save() async throws

    /// Inserts a new persistent model into the data store and returns a transformed result.
    /// - Parameters:
    ///   - insertClosure: A closure that creates a new instance of the `PersistentModelType`.
    ///   - closure: A closure that performs some operation
    ///   on the newly inserted `PersistentModelType` instance
    ///   and returns a transformed result of type `U`.
    /// - Returns: The transformed result of type `U`.
    /// - Throws: An error that indicates why the insert operation failed.
    func insert<PersistentModelType: PersistentModel, U: Sendable>(
      _ insertClosure: @Sendable @escaping () -> PersistentModelType,
      with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async rethrows -> U

    /// Retrieves an optional persistent model from the data store and returns a transformed result.
    /// - Parameters:
    ///   - selector: A `Selector<PersistentModelType>.Get` instance
    ///   that defines the criteria for retrieving the persistent model.
    ///   - closure: A closure that performs some operation on
    ///   the retrieved `PersistentModelType` instance (or `nil`)
    ///   and returns a transformed result of type `U`.
    /// - Returns: The transformed result of type `U`.
    /// - Throws: An error that indicates why the retrieval operation failed.
    func getOptional<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.Get,
      with closure: @escaping @Sendable (PersistentModelType?) throws -> U
    ) async rethrows -> U

    /// Retrieves a list of persistent models from the data store and returns a transformed result.
    /// - Parameters:
    ///   - selector: A `Selector<PersistentModelType>.List` instance
    ///   that defines the criteria for retrieving the list of persistent models.
    ///   - closure: A closure that performs some operation on t
    ///   he retrieved list of `PersistentModelType` instances and returns a transformed result of type `U`.
    /// - Returns: The transformed result of type `U`.
    /// - Throws: An error that indicates why the retrieval operation failed.
    func fetch<PersistentModelType, U: Sendable>(
      for selector: Selector<PersistentModelType>.List,
      with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
    ) async rethrows -> U

    /// Deletes one or more persistent models from the data store based on the provided selector.
    /// - Parameter selector: A `Selector<PersistentModelType>.Delete` instance
    /// that defines the criteria for deleting the persistent models.
    /// - Throws: An error that indicates why the delete operation failed.
    func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) async throws
  }
#endif
