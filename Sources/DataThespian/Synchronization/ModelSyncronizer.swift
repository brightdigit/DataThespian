//
//  ModelSyncronizer.swift
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

  /// A protocol that defines a model synchronizer.
  public protocol ModelSyncronizer {
    /// The type of the persistent model.
    associatedtype PersistentModelType: PersistentModel
    /// The type of the data to be synchronized.
    associatedtype DataType: Sendable

    /// Synchronizes the model with the provided data, using the specified database.
    ///
    /// - Parameters:
    ///   - model: The model to be synchronized.
    ///   - library: The data to be synchronized with the model.
    ///   - database: The database to be used for the synchronization.
    /// - Throws: Any errors that may occur during the synchronization process.
    static func synchronizeModel(
      _ model: Model<PersistentModelType>,
      with library: DataType,
      using database: any Database
    ) async throws
  }
#endif
