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
  public import SwiftData

  /// Simplied and customizable `ModelActor` ``Database``.
  public actor ModelActorDatabase: Database, ModelActor {
    /// The model executor used by this database.
    public nonisolated let modelExecutor: any SwiftData.ModelExecutor
    /// The model container used by this database.
    public nonisolated let modelContainer: SwiftData.ModelContainer

    /// Initializes a new `ModelActorDatabase` with the given `modelContainer`.
    /// - Parameter modelContainer: The model container to use for this database.
    public init(modelContainer: SwiftData.ModelContainer) {
      self.init(
        modelContainer: modelContainer,
        modelContext: ModelContext.init
      )
    }

    /// Initializes a new `ModelActorDatabase` with
    /// the given `modelContainer` and a custom `modelContext` closure.
    /// - Parameters:
    ///   - modelContainer: The model container to use for this database.
    ///   - closure: A closure that creates a
    ///   custom `ModelContext` from the `ModelContainer`.
    public init(
      modelContainer: SwiftData.ModelContainer,
      modelContext closure: @Sendable @escaping (ModelContainer) -> ModelContext
    ) {
      self.init(
        modelContainer: modelContainer,
        modelExecutor: DefaultSerialModelExecutor.create(from: closure)
      )
    }

    /// Initializes a new `ModelActorDatabase` with
    /// the given `modelContainer` and a custom `modelExecutor` closure.
    /// - Parameters:
    ///   - modelContainer: The model container to use for this database.
    ///   - closure: A closure that creates
    ///   a custom `ModelExecutor` from the `ModelContainer`.
    public init(
      modelContainer: SwiftData.ModelContainer,
      modelExecutor closure: @Sendable @escaping (ModelContainer) -> any ModelExecutor
    ) {
      self.init(
        modelExecutor: closure(modelContainer),
        modelContainer: modelContainer
      )
    }

    private init(modelExecutor: any ModelExecutor, modelContainer: ModelContainer) {
      self.modelExecutor = modelExecutor
      self.modelContainer = modelContainer
    }
  }

  extension DefaultSerialModelExecutor {
    fileprivate static func create(
      from closure: @Sendable @escaping (ModelContainer) -> ModelContext
    ) -> @Sendable (ModelContainer) -> any ModelExecutor {
      {
        DefaultSerialModelExecutor(modelContext: closure($0))
      }
    }
  }
#endif
