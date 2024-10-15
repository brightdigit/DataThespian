//
//  Queryable.swift
//  DataThespian
//
//  Created by Leo Dion on 10/14/24.
//

public import SwiftData
public import Foundation

public enum Selector<T : PersistentModel> : Sendable {
  public enum Delete : Sendable{
    case predicate(Predicate<T>)
    case all
    case model(Model<T>)
  }
  public enum List : Sendable{
    case descriptor(FetchDescriptor<T>)
  }
  public enum Get : Sendable{
    case model(Model<T>)
    case predicate(Predicate<T>)
  }
}

public protocol Queryable {
  func insert<PersistentModelType: PersistentModel, U : Sendable>(
    _ closuer: @Sendable @escaping () -> PersistentModelType,
    with closure: @escaping @Sendable (PersistentModelType) throws -> U
  ) async -> Model<PersistentModelType>
  
  func get<PersistentModelType, U:Sendable>(
    for selector: Selector<PersistentModelType>.Get,
    with closure: @escaping @Sendable (PersistentModelType?) throws -> U
  ) async rethrows -> U
  
  func fetch<PersistentModelType, U:Sendable>(
    for selector: Selector<PersistentModelType>.List,
    with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
  ) async rethrows -> U

  func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) async throws
}

extension Queryable {
  func insert<PersistentModelType: PersistentModel>(
    _ closuer: @Sendable @escaping () -> PersistentModelType
  ) async -> Model<PersistentModelType> {
    await self.insert(closuer, with: Model.init)
  }
  
  func get<PersistentModelType>(
    for selector: Selector<PersistentModelType>.Get
  ) async -> Model<PersistentModelType>? {
    await self.get(for: selector) { persistentModel in
      persistentModel.flatMap(Model.init)
    }
  }
  
  func fetch<PersistentModelType>(
    for selector: Selector<PersistentModelType>.List
  ) async -> [Model<PersistentModelType>] {
    await self.fetch(for: selector) { persistentModels in
      persistentModels.map(Model.init)
    }
  }
}
