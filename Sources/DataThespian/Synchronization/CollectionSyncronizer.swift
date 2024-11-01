//
//  CollectionSyncronizer.swift
//  DataThespian
//
//  Created by Leo Dion on 11/1/24.
//

public import SwiftData

private struct SynchronizationUpdate<PersistentModelType: PersistentModel, DataType: Sendable> {
  var file: DataType?
  var entry: PersistentModelType?
}


public protocol CollectionSyncronizer {
  associatedtype PersistentModelType: PersistentModel
  associatedtype DataType: Sendable
  associatedtype ID: Hashable

  static var dataKey: KeyPath<DataType, ID> { get }
  static var persistentModelKey: KeyPath<PersistentModelType, ID> { get }

  static func getSelector(from data: DataType) -> DataThespian.Selector<PersistentModelType>.Get

  static func persistentModel(from data: DataType) -> PersistentModelType
  static func syncronize(_ persistentModel: PersistentModelType, with data: DataType) throws
}



extension CollectionSyncronizer {
  public static func syncronizeDifference
  (
    _ difference: CollectionDifference<PersistentModelType, DataType>,
    using modelContext: ModelContext
  ) throws -> [PersistentModelType] {
    // try await database.withModelContext { modelContext in
    try modelContext.delete(difference.deleteSelectors)

    let modelsToInsert: [Model<PersistentModelType>] = difference.inserts.map { model in
      modelContext.insert {
        Self.persistentModel(from: model)
      }
    }

    let inserted = try modelsToInsert.map {
      try modelContext.get($0)
    }
//      for insertedModel in modelsToInsert {
//        let inserted = try modelContext.get(insertedModel)
//        Self.onInsertedModel(inserted, with: helpers)
//      }

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
    // try modelContext.save()
    // }
  }
}
