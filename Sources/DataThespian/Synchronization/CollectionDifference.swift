//
// Temp.swift
// Copyright (c) 2024 BrightDigit.
//

public import SwiftData



public struct CollectionDifference<PersistentModelType: PersistentModel, DataType: Sendable>: Sendable {
  public init(inserts: [DataType], modelsToDelete: [Model<PersistentModelType>], updates: [DataType]) {
    self.inserts = inserts
    self.modelsToDelete = modelsToDelete
    self.updates = updates
  }

  public let inserts: [DataType]
  public let modelsToDelete: [Model<PersistentModelType>]
  public let updates: [DataType]
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
    let entryMap: [ID: PersistentModelType] = .init(uniqueKeysWithValues: persistentModels.map {
      ($0[keyPath: persistentModelKeyPath], $0)
    })

    let data = data ?? []
    let imageMap: [ID: DataType] = .init(uniqueKeysWithValues: data.map {
      ($0[keyPath: dataKeyPath], $0)
    })

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


