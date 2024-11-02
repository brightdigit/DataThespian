//
//  UniqueKeyPath.swift
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

/// A struct that represents a unique key path for a model type.
public struct UniqueKeyPath<Model: Unique, ValueType: Sendable & Equatable & Codable>: UniqueKey {
  /// The key path for the model type.
  private let keyPath: KeyPath<Model, ValueType> & Sendable

  /// Initializes a new instance of `UniqueKeyPath` with the given key path.
  ///
  /// - Parameter keyPath: The key path for the model type.
  internal init(keyPath: any KeyPath<Model, ValueType> & Sendable) {
    self.keyPath = keyPath
  }

  /// Creates a predicate that checks if the value of the key path is equal to the given value.
  ///
  /// - Parameter value: The value to compare against.
  /// - Returns: A predicate that can be used to filter models.
  public func predicate(equals value: ValueType) -> Predicate<Model> {
    fatalError("Not implemented yet.")
  }
}
