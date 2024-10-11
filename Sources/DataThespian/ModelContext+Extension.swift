//
//  ModelContext+Extension.swift
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

public import Foundation
public import SwiftData

extension ModelContext {
  public func delete<T: PersistentModel>(_: T.Type, withID id: PersistentIdentifier) -> Bool {
    guard let model: T = self.registeredModel(for: id) else { return false }
    self.delete(model)
    return true
  }

  public func delete<T>(where predicate: Predicate<T>?) throws where T: PersistentModel {
    try self.delete(model: T.self, where: predicate)
  }

  public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel)
    -> PersistentIdentifier
  {
    let model = closuer()
    self.insert(model)
    return model.persistentModelID
  }
  public func fetch<T, U>(
    _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
    with closure: @escaping @Sendable ([T]) throws -> U
  ) throws -> U where T: PersistentModel, U: Sendable {
    let models = try self.fetch(selectDescriptor())
    return try closure(models)
  }
  public func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
    _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
    _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
    with closure: @escaping @Sendable ([T], [U]) throws -> V
  ) throws -> V {
    let firstModels = try self.fetch(selectDescriptorA())
    let secondModels = try self.fetch(selectDescriptorB())
    return try closure(firstModels, secondModels)
  }

  public func get<T, U>(
    for objectID: PersistentIdentifier, with closure: @escaping @Sendable (T?) throws -> U
  ) throws -> U where T: PersistentModel, U: Sendable {
    let model: T? = try self.existingModel(for: objectID)
    return try closure(model)
  }

  public func transaction(block: @escaping @Sendable (ModelContext) throws -> Void) throws {
    try self.transaction { try block(self) }
  }
}
