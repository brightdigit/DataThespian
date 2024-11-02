//
//  ModelDifferenceSyncronizer.swift
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
  /// A protocol that defines the requirements for a synchronizer that can synchronize model differences.
  public protocol ModelDifferenceSyncronizer: ModelSyncronizer {
    /// The type of synchronization difference used by this synchronizer.
    associatedtype SynchronizationDifferenceType: SynchronizationDifference
    where
      SynchronizationDifferenceType.DataType == DataType,
      SynchronizationDifferenceType.PersistentModelType == PersistentModelType

    /// Synchronizes the given synchronization difference with the database.
    ///
    /// - Parameters:
    ///   - diff: The synchronization difference to be synchronized.
    ///   - database: The database to be used for the synchronization.
    /// - Throws: An error that may occur during the synchronization process.
    static func synchronize(
      _ diff: SynchronizationDifferenceType,
      using database: any Database
    ) async throws
  }

  extension ModelDifferenceSyncronizer {
    /// Synchronizes the given model with the library using the database.
    ///
    /// - Parameters:
    ///   - model: The model to be synchronized.
    ///   - library: The library to be used for the synchronization.
    ///   - database: The database to be used for the synchronization.
    /// - Throws: An error that may occur during the synchronization process.
    public static func synchronizeModel(
      _ model: Model<PersistentModelType>,
      with library: DataType,
      using database: any Database
    ) async throws {
      let diff = try await database.get(for: .model(model)) { libraryEntry in
        SynchronizationDifferenceType.comparePersistentModel(libraryEntry, with: library)
      }

      return try await self.synchronize(diff, using: database)
    }
  }
#endif
