//
//  Selector.swift
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
  /// A type that represents a selector for interacting with a `PersistentModel`.
  public enum Selector<T: PersistentModel>: Sendable {
    /// A type that represents a way to delete data from a `PersistentModel`.
    public enum Delete: Sendable {
      /// Deletes data that matches the provided `Predicate`.
      case predicate(Predicate<T>)
      /// Deletes all data for the `PersistentModel`.
      case all
      /// Deletes the provided `Model`.
      case model(Model<T>)
    }

    /// A type that represents a way to fetch data from a `PersistentModel`.
    public enum List: Sendable {
      /// Fetches data using the provided `FetchDescriptor`.
      case descriptor(FetchDescriptor<T>)
    }

    /// A type that represents a way to retrieve a `PersistentModel`.
    public enum Get: Sendable {
      /// Retrieves the `Model` with the provided `Model`.
      case model(Model<T>)
      /// Retrieves the `PersistentModel` instances that match the provided `Predicate`.
      case predicate(Predicate<T>)
    }
  }

  extension Selector.Get {
    /// Retrieves the `PersistentModel` instance with the provided unique key value.
    ///
    /// - Parameters:
    ///   - key: The unique key to search for.
    ///   - value: The value of the unique key to search for.
    /// - Returns: A `Selector.Get` case that can be used to retrieve the `PersistentModel` instance.
    @available(*, unavailable, message: "Not implemented yet.")
    public static func unique<UniqueKeyableType: UniqueKey>(
      _ key: UniqueKeyableType,
      equals value: UniqueKeyableType.ValueType
    ) -> Self where UniqueKeyableType.Model == T {
      .predicate(
        key.predicate(equals: value)
      )
    }
  }

  extension Selector.List {
    /// Creates a `Selector.List` case
    /// that fetches `PersistentModel` instances using the provided parameters.
    ///
    /// - Parameters:
    ///   - type: The type of `PersistentModel` to fetch.
    ///   - predicate: An optional `Predicate` to filter the results.
    ///   - sortBy: An optional array of `SortDescriptor` instances to sort the results.
    ///   - fetchLimit: An optional limit on the number of results to fetch.
    /// - Returns: A `Selector.List` case that can be used to fetch `PersistentModel` instances.
    public static func descriptor(
      _ type: T.Type,
      predicate: Predicate<T>? = nil,
      sortBy: [SortDescriptor<T>] = [],
      fetchLimit: Int? = nil
    ) -> Selector.List {
      .descriptor(.init(predicate: predicate, sortBy: sortBy, fetchLimit: fetchLimit))
    }

    /// Creates a `Selector.List` case that fetches `PersistentModel` instances
    /// using the provided parameters.
    ///
    /// - Parameters:
    ///   - predicate: An optional `Predicate` to filter the results.
    ///   - sortBy: An optional array of `SortDescriptor` instances to sort the results.
    ///   - fetchLimit: An optional limit on the number of results to fetch.
    /// - Returns: A `Selector.List` case that can be used to fetch `PersistentModel` instances.
    public static func descriptor(
      predicate: Predicate<T>? = nil,
      sortBy: [SortDescriptor<T>] = [],
      fetchLimit: Int? = nil
    ) -> Selector.List {
      .descriptor(.init(predicate: predicate, sortBy: sortBy, fetchLimit: fetchLimit))
    }

    /// Creates a `Selector.List` case that fetches all `PersistentModel` instances of the provided type.
    ///
    /// - Parameter type: The type of `PersistentModel` to fetch.
    /// - Returns: A `Selector.List` case
    /// that can be used to fetch all `PersistentModel` instances of the provided type.
    public static func all(_ type: T.Type) -> Selector.List {
      .descriptor(.init())
    }

    /// Creates a `Selector.List` case that fetches all `PersistentModel` instances.
    ///
    /// - Returns: A `Selector.List` case that can be used to fetch all `PersistentModel` instances.
    public static func all() -> Selector.List {
      .descriptor(.init())
    }
  }
#endif
