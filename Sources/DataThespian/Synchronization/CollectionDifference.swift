//
//  CollectionDifference.swift
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
  public import SwiftData
  /// Represents the difference between a persistent model and its associated data.
  public struct CollectionDifference<PersistentModelType: PersistentModel, DataType: Sendable>:
    Sendable
  {
    /// The items that need to be inserted.
    public let inserts: [DataType]
    /// The models that need to be deleted.
    public let modelsToDelete: [Model<PersistentModelType>]
    /// The items that need to be updated.
    public let updates: [DataType]

    /// Initializes a `CollectionDifference` instance with
    /// the specified inserts, models to delete, and updates.
    /// - Parameters:
    ///   - inserts: The items that need to be inserted.
    ///   - modelsToDelete: The models that need to be deleted.
    ///   - updates: The items that need to be updated.
    public init(
      inserts: [DataType], modelsToDelete: [Model<PersistentModelType>], updates: [DataType]
    ) {
      self.inserts = inserts
      self.modelsToDelete = modelsToDelete
      self.updates = updates
    }
  }

  extension CollectionDifference {
    /// The delete selectors for the models that need to be deleted.
    public var deleteSelectors: [DataThespian.Selector<PersistentModelType>.Delete] {
      self.modelsToDelete.map {
        .model($0)
      }
    }

    /// Initializes a `CollectionDifference` instance by comparing the persistent models and data.
    /// - Parameters:
    ///   - persistentModels: The persistent models to compare.
    ///   - data: The data to compare.
    ///   - persistentModelKeyPath: The key path to the unique identifier in the persistent models.
    ///   - dataKeyPath: The key path to the unique identifier in the data.
    public init<ID: Hashable>(
      persistentModels: [PersistentModelType]?,
      data: [DataType]?,
      persistentModelKeyPath: KeyPath<PersistentModelType, ID>,
      dataKeyPath: KeyPath<DataType, ID>
    ) {
      let persistentModels = persistentModels ?? []
      let entryMap: [ID: PersistentModelType] =
        .init(
          uniqueKeysWithValues: persistentModels.map {
            ($0[keyPath: persistentModelKeyPath], $0)
          }
        )

      let data = data ?? []
      let dataMap: [ID: DataType] = .init(
        uniqueKeysWithValues: data.map {
          ($0[keyPath: dataKeyPath], $0)
        }
      )

      let entryIDsToUpdate = Set(entryMap.keys).intersection(dataMap.keys)
      let entryIDsToDelete = Set(entryMap.keys).subtracting(dataMap.keys)
      let entryIDsToInsert = Set(dataMap.keys).subtracting(entryMap.keys)

      let entriesToDelete = entryIDsToDelete.compactMap { entryMap[$0] }.map(Model.init)
      let entryItemsToInsert = entryIDsToInsert.compactMap { dataMap[$0] }
      let entriesToUpdate = entryIDsToUpdate.compactMap {
        dataMap[$0]
      }

      assert(entryIDsToUpdate.count == entriesToUpdate.count)
      assert(entryIDsToDelete.count == entriesToDelete.count)
      assert(entryItemsToInsert.count == entryIDsToInsert.count)

      self.init(
        inserts: entryItemsToInsert,
        modelsToDelete: entriesToDelete,
        updates: entriesToUpdate
      )
    }
  }
#endif
