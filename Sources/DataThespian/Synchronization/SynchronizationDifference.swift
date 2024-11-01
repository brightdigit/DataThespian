//
//  SynchronizationDifference.swift
//  DataThespian
//
//  Created by Leo Dion on 11/1/24.
//

public import SwiftData



public protocol SynchronizationDifference: Sendable {
  associatedtype PersistentModelType: PersistentModel
  associatedtype DataType: Sendable

  static func comparePersistentModel(_ persistentModel: PersistentModelType, with data: DataType) -> Self
}
