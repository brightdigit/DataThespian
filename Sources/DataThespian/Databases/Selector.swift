//
//  Selector.swift
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

  public enum Selector<T: PersistentModel>: Sendable {
    public enum Delete: Sendable {
      case predicate(Predicate<T>)
      case all
      case model(Model<T>)
    }
    public enum List: Sendable {
      case descriptor(FetchDescriptor<T>)
    }
    public enum Get: Sendable {
      case model(Model<T>)
      case predicate(Predicate<T>)
    }
  }

  extension Selector.Get {
    @available(*, unavailable, message: "Not implemented yet.")
    public static func unique<UniqueKeyableType: UniqueKey>(
      _ key: UniqueKeyableType,
      equals value: UniqueKeyableType.ValueType
    ) -> Self where UniqueKeyableType.Model == T {
      .predicate(
        key.predicate(equals: value)
      )
    }
  }

  extension Selector.List {
    public static func all() -> Selector.List {
      .descriptor(.init())
    }
  }
#endif
