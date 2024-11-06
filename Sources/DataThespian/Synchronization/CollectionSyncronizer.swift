//
//  CollectionSyncronizer.swift
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
  private struct SynchronizationUpdate<PersistentModelType: PersistentModel, DataType: Sendable> {
    var file: DataType?
    var entry: PersistentModelType?
  }
  /// A protocol that defines the synchronization behavior between a persistent model and data.
  public protocol CollectionSyncronizer {
    /// The type of the persistent model.
    associatedtype PersistentModelType: PersistentModel

    /// The type of the data.
    associatedtype DataType: Sendable

    /// The type of the identifier.
    associatedtype ID: Hashable

    /// The key path to the identifier in the data.
    static var dataKey: KeyPath<DataType, ID> { get }

    /// The key path to the identifier in the persistent model.
    static var persistentModelKey: KeyPath<PersistentModelType, ID> { get }

    /// Retrieves a selector for fetching the persistent model from the data.
    ///
    /// - Parameter data: The data to use for constructing the selector.
    /// - Returns: A selector for fetching the persistent model.
    static func getSelector(from data: DataType) -> DataThespian.Selector<PersistentModelType>.Get

    /// Creates a persistent model from the provided data.
    ///
    /// - Parameter data: The data to create the persistent model from.
    /// - Returns: The created persistent model.
    static func persistentModel(from data: DataType) -> PersistentModelType

    /// Synchronizes the persistent model with the provided data.
    ///
    /// - Parameters:
    ///   - persistentModel: The persistent model to synchronize.
    ///   - data: The data to synchronize the persistent model with.
    /// - Throws: Any errors that occur during the synchronization process.
    static func syncronize(_ persistentModel: PersistentModelType, with data: DataType) throws
  }

  extension CollectionSyncronizer {
    /// Synchronizes the difference between a collection of persistent models and a collection of data.
    ///
    /// - Parameters:
    ///   - difference: The difference between the persistent models and the data.
    ///   - modelContext: The model context to use for the synchronization.
    /// - Returns: The list of persistent models that were inserted.
    /// - Throws: Any errors that occur during the synchronization process.
    public static func syncronizeDifference(
      _ difference: CollectionDifference<PersistentModelType, DataType>,
      using modelContext: ModelContext
    ) throws -> [PersistentModelType] {
      try modelContext.delete(difference.deleteSelectors)

      let modelsToInsert: [Model<PersistentModelType>] = difference.inserts.map { model in
        modelContext.insert {
          Self.persistentModel(from: model)
        }
      }

      let inserted = try modelsToInsert.map {
        try modelContext.get($0)
      }

      let updateSelectors = difference.updates.map {
        Self.getSelector(from: $0)
      }

      let entriesToUpdate = try modelContext.fetch(for: updateSelectors)

      var dictionary = [ID: SynchronizationUpdate<PersistentModelType, DataType>]()

      for file in difference.updates {
        let id = file[keyPath: Self.dataKey]
        assert(dictionary[id] == nil)
        dictionary[id] = SynchronizationUpdate(file: file)
      }

      for entry in entriesToUpdate {
        let id = entry[keyPath: Self.persistentModelKey]
        assert(dictionary[id] != nil)
        dictionary[id]?.entry = entry
      }

      for update in dictionary.values {
        guard let entry = update.entry, let file = update.file else {
          assertionFailure()
          continue
        }
        try Self.syncronize(entry, with: file)
      }

      return inserted
    }
  }
#endif
