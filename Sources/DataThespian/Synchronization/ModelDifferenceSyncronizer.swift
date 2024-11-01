//
//  ModelDifferenceSyncronizer.swift
//  DataThespian
//
//  Created by Leo Dion on 11/1/24.
//

public import SwiftData

public protocol ModelDifferenceSyncronizer: ModelSyncronizer {
  associatedtype SynchronizationDifferenceType: SynchronizationDifference where
    SynchronizationDifferenceType.DataType == DataType,
    SynchronizationDifferenceType.PersistentModelType == PersistentModelType
  
  static func synchronize(
    _ diff: SynchronizationDifferenceType,
    using database: any Database
  ) async throws
}

extension ModelDifferenceSyncronizer {
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
