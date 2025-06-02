//
//  AnyModel.swift
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
  import Foundation
  public import SwiftData

  /// Phantom Type for easily retrieving fetching `PersistentModel` objects from a `ModelContext`.
  public struct AnyModel: Sendable, Identifiable {
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

  extension AnyModel {
    /// A boolean value indicating whether the model is temporary or not.
    public var isTemporary: Bool {
      self.persistentIdentifier.isTemporary ?? false
    }

    /// Initializes a new `Model` instance with the specified `PersistentModel`.
    ///
    /// - Parameter model: The `PersistentModel` to initialize the `Model` with.
    public init(_ model: any PersistentModel) {
      self.init(persistentIdentifier: model.persistentModelID)
    }

    /// Type erases the ``Model``
    /// - Parameter typeErase: Original ``Model``.
    public init(typeErase: Model<some PersistentModel>) {
      self.init(persistentIdentifier: typeErase.persistentIdentifier)
    }
  }

  extension Model {
    /// Creates a typed ``Model``
    /// - Parameters:
    ///   - anyModel: ``AnyModel``
    ///   - _:  ``Model`` type.
    public init(anyModel: AnyModel, type _: T.Type) {
      self.init(persistentIdentifier: anyModel.persistentIdentifier)
    }
  }
#endif
