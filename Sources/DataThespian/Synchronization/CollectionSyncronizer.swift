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
