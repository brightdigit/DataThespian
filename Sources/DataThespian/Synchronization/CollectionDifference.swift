//
//  CollectionDifference.swift
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

  public struct CollectionDifference<
    PersistentModelType: PersistentModel,
    DataType: Sendable
  >: Sendable {
    public let inserts: [DataType]
    public let modelsToDelete: [Model<PersistentModelType>]
    public let updates: [DataType]

    public init(
      inserts: [DataType],
      modelsToDelete: [Model<PersistentModelType>],
      updates: [DataType]
    ) {
      self.inserts = inserts
      self.modelsToDelete = modelsToDelete
      self.updates = updates
    }
  }

  extension CollectionDifference {
    public var deleteSelectors: [DataThespian.Selector<PersistentModelType>.Delete] {
      self.modelsToDelete.map {
        .model($0)
      }
    }

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
      let imageMap: [ID: DataType] = .init(
        uniqueKeysWithValues: data.map {
          ($0[keyPath: dataKeyPath], $0)
        }
      )

      let entryIDsToUpdate = Set(entryMap.keys).intersection(imageMap.keys)
      let entryIDsToDelete = Set(entryMap.keys).subtracting(imageMap.keys)
      let libraryIDsToInsert = Set(imageMap.keys).subtracting(entryMap.keys)

      let entriesToDelete = entryIDsToDelete.compactMap { entryMap[$0] }.map(Model.init)
      let libraryItemsToInsert = libraryIDsToInsert.compactMap { imageMap[$0] }
      let imagesToUpdate = entryIDsToUpdate.compactMap {
        imageMap[$0]
      }

      assert(entryIDsToUpdate.count == imagesToUpdate.count)
      assert(entryIDsToDelete.count == entriesToDelete.count)
      assert(libraryItemsToInsert.count == libraryIDsToInsert.count)

      self.init(
        inserts: libraryItemsToInsert,
        modelsToDelete: entriesToDelete,
        updates: imagesToUpdate
      )
    }
  }
#endif
