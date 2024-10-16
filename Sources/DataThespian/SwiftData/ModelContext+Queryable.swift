//
//  ModelContext+Queryable.swift
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

extension ModelContext {
  public func insert<PersistentModelType: PersistentModel, U: Sendable>(
    _ closuer: @Sendable @escaping () -> PersistentModelType,
    with closure: @escaping @Sendable (PersistentModelType) throws -> U
  ) rethrows -> U {
    let persistentModel = closuer()
    self.insert(persistentModel)
    return try closure(persistentModel)
  }

  public func getOptional<PersistentModelType, U: Sendable>(
    for selector: Selector<PersistentModelType>.Get,
    with closure: @escaping @Sendable (PersistentModelType?) throws -> U
  ) throws -> U {
    let persistentModel: PersistentModelType?
    switch selector {
    case .model(let model):
      persistentModel = try self.existingModel(for: model)
    case .predicate(let predicate):
      persistentModel = try self.first(where: predicate)
    }
    return try closure(persistentModel)
  }

  public func fetch<PersistentModelType, U: Sendable>(
    for selector: Selector<PersistentModelType>.List,
    with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
  ) throws -> U {
    let persistentModels: [PersistentModelType]
    switch selector {
    case .descriptor(let descriptor):
      persistentModels = try self.fetch(descriptor)
    }
    return try closure(persistentModels)
  }

  public func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) throws {
    switch selector {
    case .all:
      try self.delete(model: PersistentModelType.self)
    case .model(let model):
      if let persistentModel = try self.existingModel(for: model) {
        self.delete(persistentModel)
      }
    case .predicate(let predicate):
      try self.delete(model: PersistentModelType.self, where: predicate)
    }
  }
}
