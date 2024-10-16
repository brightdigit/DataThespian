//
//  Database+ModelContext.swift
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

  extension Database {
    @discardableResult public func delete<T: PersistentModel>(
      _ modelType: T.Type, withID id: PersistentIdentifier
    ) async -> Bool { await self.withModelContext { $0.delete(modelType, withID: id) } }

    public func delete<T: PersistentModel>(where predicate: Predicate<T>?) async throws {
      try await self.withModelContext { try $0.delete(where: predicate) }
    }

    //    public func insert(_ closuer: @Sendable @escaping () -> some PersistentModel) async
    //      -> PersistentIdentifier
    //    { await self.withModelContext { $0.insert(closuer) } }

    public func fetch<T, U: Sendable>(
      _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
      with closure: @escaping @Sendable ([T]) throws -> U
    ) async rethrows -> U {
      try await self.withModelContext { try $0.fetch(selectDescriptor, with: closure) }
    }

    public func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
      _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
      _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
      with closure: @escaping @Sendable ([T], [U]) throws -> V
    ) async rethrows -> V {
      try await self.withModelContext {
        try $0.fetch(selectDescriptorA, selectDescriptorB, with: closure)
      }
    }

    public func get<T, U: Sendable>(
      for objectID: PersistentIdentifier, with closure: @escaping @Sendable (T?) throws -> U
    ) async rethrows -> U where T: PersistentModel {
      try await self.withModelContext { try $0.get(for: objectID, with: closure) }
    }

    public func transaction(_ block: @Sendable @escaping (ModelContext) throws -> Void) async throws
    { try await self.withModelContext { try $0.transaction(block: block) } }
  }

#endif
