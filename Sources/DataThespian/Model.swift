//
//  Model.swift
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
  /// A struct that represents a model in the DataThespian application.
  ///
  /// This struct is used to wrap a `PersistentModel` object and provides
  /// a convenient way to work with the model.
  public struct Model<T: PersistentModel>: Sendable, Identifiable {
    /// An error that is thrown when a `PersistentModel`
    /// with the specified `PersistentIdentifier` is not found.
    public struct NotFoundError: Error {
      /// The `PersistentIdentifier` of the `PersistentModel` that was not found.
      public let persistentIdentifier: PersistentIdentifier
    }

    /// The unique identifier of the model.
    public var id: PersistentIdentifier.ID { persistentIdentifier.id }

    /// The `PersistentIdentifier` of the model.
    public let persistentIdentifier: PersistentIdentifier

    /// Initializes a new `Model` instance with the specified `PersistentIdentifier`.
    ///
    /// - Parameter persistentIdentifier: The `PersistentIdentifier` of the model.
    public init(persistentIdentifier: PersistentIdentifier) {
      self.persistentIdentifier = persistentIdentifier
    }
  }

  extension Model where T: PersistentModel {
    /// A boolean value indicating whether the model is temporary or not.
    public var isTemporary: Bool {
      self.persistentIdentifier.isTemporary ?? false
    }

    /// Initializes a new `Model` instance with the specified `PersistentModel`.
    ///
    /// - Parameter model: The `PersistentModel` to initialize the `Model` with.
    public init(_ model: T) {
      self.init(persistentIdentifier: model.persistentModelID)
    }

    /// Creates a new `Model` instance from the specified `PersistentModel`.
    ///
    /// - Parameter model: The `PersistentModel` to create the `Model` from.
    /// - Returns: A new `Model` instance, or `nil` if the `PersistentModel` is `nil`.
    internal static func ifMap(_ model: T?) -> Model? {
      model.map(self.init)
    }
  }
#endif
