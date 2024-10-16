//
//  BackgroundDatabase.swift
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
  import Foundation
  public import SwiftData

  public final class BackgroundDatabase: Database {
    private actor DatabaseContainer {
      private let factory: @Sendable () -> any Database
      private var wrappedTask: Task<any Database, Never>?

      // swiftlint:disable:next strict_fileprivate
      fileprivate init(factory: @escaping @Sendable () -> any Database) { self.factory = factory }

      // swiftlint:disable:next strict_fileprivate
      fileprivate var database: any Database {
        get async {
          if let wrappedTask {
            return await wrappedTask.value
          }
          let task = Task { factory() }
          self.wrappedTask = task
          return await task.value
        }
      }
    }

    private let container: DatabaseContainer

    private var database: any Database { get async { await container.database } }

    public convenience init(database: @Sendable @escaping @autoclosure () -> any Database) {
      self.init(database)
    }

    public init(_ factory: @Sendable @escaping () -> any Database) {
      self.container = .init(factory: factory)
    }

    public func withModelContext<T>(_ closure: @Sendable @escaping (ModelContext) throws -> T)
      async rethrows -> T
    { try await self.database.withModelContext(closure) }
  }

  extension BackgroundDatabase {
    public convenience init(
      modelContainer: ModelContainer,
      modelContext closure: (@Sendable (ModelContainer) -> ModelContext)? = nil
    ) {
      let closure = closure ?? ModelContext.init
      self.init(database: ModelActorDatabase(modelContainer: modelContainer, modelContext: closure))
    }

    public convenience init(
      modelContainer: SwiftData.ModelContainer
    ) {
      self.init(
        modelContainer: modelContainer,
        modelContext: ModelContext.init
      )
    }

    public convenience init(
      modelContainer: SwiftData.ModelContainer,
      modelExecutor closure: @Sendable @escaping (ModelContainer) -> any ModelExecutor
    ) {
      self.init(
        database: ModelActorDatabase(
          modelContainer: modelContainer,
          modelExecutor: closure
        )
      )
    }
  }
#endif
