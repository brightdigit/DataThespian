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

#if canImport(SwiftData)
  public import Foundation
  public import SwiftData

  extension ModelContext {
    public func insert<T: PersistentModel>(_ closuer: @escaping @Sendable () -> T)
      -> Model<T>
    {
      let model = closuer()
      self.insert(model)
      return .init(model)
    }

    public func fetch<PersistentModelType>(
      for selectors: [Selector<PersistentModelType>.Get]
    )  throws -> [PersistentModelType] {
      try selectors
        .map {
        try self.getOptional(for: $0)
        }
      .compactMap { $0 }
    }

    public func get<T>(_ model: Model<T>) throws -> T
    where T: PersistentModel {
      guard let item = try self.getOptional(model) else {
        throw QueryError.itemNotFound(.model(model))
      }
      return item
    }

    public func delete<PersistentModelType>(
      _ selectors: [Selector<PersistentModelType>.Delete]
    ) throws {
      for selector in selectors {
        try self.delete(selector)
      }
    }

    public func first<PersistentModelType: PersistentModel>(
      where predicate: Predicate<PersistentModelType>? = nil
    ) throws -> PersistentModelType? {
      try self.fetch(FetchDescriptor(predicate: predicate, fetchLimit: 1)).first
    }
  }
#endif
