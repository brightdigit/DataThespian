//
//  Model.swift
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

  @available(*, deprecated, renamed: "Model")
  public typealias ModelID = Model

  public struct Model<T: PersistentModel>: Sendable, Identifiable {
    public struct NotFoundError: Error { public let persistentIdentifier: PersistentIdentifier }

    public var id: PersistentIdentifier.ID { persistentIdentifier.id }
    public let persistentIdentifier: PersistentIdentifier

    public init(persistentIdentifier: PersistentIdentifier) {
      self.persistentIdentifier = persistentIdentifier
    }
  }

  extension Model where T: PersistentModel {
    public var isTemporary: Bool {
      self.persistentIdentifier.isTemporary ?? false
    }

    public init(_ model: T) { self.init(persistentIdentifier: model.persistentModelID) }

    internal static func ifMap(_ model: T?) -> Model? { model.map(self.init) }
  }
#endif
