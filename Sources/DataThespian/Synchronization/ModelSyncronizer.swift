//
//  ModelSyncronizer.swift
//  DataThespian
//
//  Created by Leo Dion on 11/1/24.
//

public import SwiftData


public protocol ModelSyncronizer {
  associatedtype PersistentModelType: PersistentModel
  associatedtype DataType: Sendable

  static func synchronizeModel(
    _ model: Model<PersistentModelType>,
    with library: DataType,
    using database: any Database
  ) async throws
}
