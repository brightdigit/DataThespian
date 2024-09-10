//
//  ModelActorDatabase.swift
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

  public import Foundation

  public import SwiftData

public enum Pack {
  public static func descriptors<each Model: PersistentModel>(
    _ descriptors: repeat @escaping @Sendable() -> FetchDescriptor<each Model>) -> (repeat FetchDescriptor<each Model>){
      return (repeat (each descriptors)())
  }  
}

extension ModelContext {
  func fetch<each T: PersistentModel, Result: Sendable>(
  _ descriptor: repeat FetchDescriptor<each T>,
  with closure: @escaping @Sendable (repeat [each T]) throws -> Result
  ) throws -> Result {
  try closure (repeat try fetch(each descriptor))
  }
}

  @ModelActor public actor ModelActorDatabase: Database, Loggable {
    public func delete<T: PersistentModel>(_: T.Type, withID id: PersistentIdentifier) async -> Bool
    {
      guard let model: T = self.modelContext.registeredModel(for: id) else { return false }
      self.modelContext.delete(model)
      return true
    }

    public func delete<T>(where predicate: Predicate<T>?) async throws where T: PersistentModel {
      try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func insert(_ closuer: @escaping @Sendable () -> some PersistentModel) async
      -> PersistentIdentifier
    {
      let model = closuer()
      self.modelContext.insert(model)
      return model.persistentModelID
    }
    
//    public func fetch<each T: PersistentModel, Result: Sendable>(
//      _ descriptor: @Sendable () -> (repeat  (FetchDescriptor<each T>)),
//    with closure: @escaping @Sendable (repeat [each T]) throws -> Result
//    ) async throws -> Result {
//      try closure(
//        try    self.modelContext.fetch(repeat each descriptor())
//      )
//    }
    
//    public func fetchA<each T: PersistentModel, Result: Sendable>(
//    _ descriptor: repeat FetchDescriptor<each T>,
//    with closure: @escaping @Sendable (repeat [each T]) throws -> Result
//    ) async throws -> Result {
//      try self.modelContext.fetch(repeat each descriptor, with: closure)
//    }
    
    public func fetch<T, U>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
      with closure: @escaping @Sendable ([T]) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      let models = try self.modelContext.fetch(selectDescriptor())
      return try closure(models)
    }
    
    public func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
      _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
      _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
      with closure: @escaping @Sendable ([T], [U]) throws -> V
    ) async throws -> V {
      let a = try self.modelContext.fetch(selectDescriptorA())
      let b = try self.modelContext.fetch(selectDescriptorB())
      return try closure(a, b)
    }

    public func get<T, U>(
      for objectID: PersistentIdentifier,
      with closure: @escaping @Sendable (T?) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      let model: T? = try self.modelContext.existingModel(for: objectID)
      return try closure(model)
    }
    
  
    public func fetchA<each T: PersistentModel, U: Sendable>(
      _ selectDescriptor: @escaping @Sendable () -> (repeat FetchDescriptor<each T>),
      with closure: @escaping @Sendable (repeat ([each T])) throws -> U
    ) async throws -> U where  U: Sendable {
      return try closure(
        repeat try self.modelContext.fetch(each selectDescriptor())
      )
    }
    
//    public func fetch<each T: PersistentModel, Result: Sendable> (
//    descriptor: repeat @escaping @Sendable() -> FetchDescriptor<each T>,
//    with closure: @escaping @Sendable (repeat [each T]) throws -> Result)
//    async throws -> Result {
//      fatalError()
//    }
    
    
    public static var loggingCategory: ThespianLogging.Category { .data }

    public func transaction(_ block: @escaping @Sendable (ModelContext) throws -> Void) async throws
    {
      assert(isMainThread: false)

      try self.modelContext.transaction {
        assert(isMainThread: false)
        try block(modelContext)
      }
    }
  }

#endif
