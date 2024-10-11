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

  import Foundation

  public import SwiftData

  @available(*, deprecated, message: "Create your own.")
  public actor ModelActorDatabase: ModelActor, Database, Loggable {
    public static var loggingCategory: ThespianLogging.Category { .data }

    public nonisolated let modelExecutor: any SwiftData.ModelExecutor

    public nonisolated let modelContainer: SwiftData.ModelContainer

    public init(modelContainer: SwiftData.ModelContainer, autosaveEnabled: Bool = false) {
      let modelContext = ModelContext(modelContainer)
      modelContext.autosaveEnabled = autosaveEnabled

      let modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
      self.init(modelExecutor: modelExecutor, modelContainer: modelContainer)
    }
    private init(modelExecutor: any ModelExecutor, modelContainer: ModelContainer) {
      self.modelExecutor = modelExecutor
      self.modelContainer = modelContainer
    }
  }

#endif
