//
//  UniqueKeys.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

/// A protocol that defines the rules for a type that represents the unique keys for a `Model` type.
///
/// The `UniqueKeys` protocol has two associated type requirements:
///
/// - `Model`: The type for which the unique keys are defined.
/// This type must conform to the `Unique` protocol.
/// - `PrimaryKey`: The type that represents the primary key for the `Model` type.
/// This type must conform to the `UniqueKey` protocol, and
/// its `Model` associated type must be the same as
/// the `Model` associated type of the `UniqueKeys` protocol.
///
/// The protocol also has a static property requirement, `primary`,
/// which returns the primary key for the `Model` type.
@_documentation(visibility: internal)
public protocol UniqueKeys<Model>: Sendable {
  /// The type for which the unique keys are defined. This type must conform to the `Unique` protocol.
  associatedtype Model: Unique

  /// The type that represents the primary key for the `Model` type.
  /// This type must conform to the `UniqueKey` protocol, and
  /// its `Model` associated type must be the same as
  /// the `Model` associated type of the `UniqueKeys` protocol.
  associatedtype PrimaryKey: UniqueKey where PrimaryKey.Model == Model

  /// The primary key for the `Model` type.
  static var primary: PrimaryKey { get }
}

extension UniqueKeys {
  /// Creates a `UniqueKeyPath` instance for the specified key path.
  ///
  /// - Parameter keyPath: A key path for a property of
  /// the `Model` type. The property must be `Sendable`, `Equatable`, and `Codable`.
  /// - Returns: A `UniqueKeyPath` instance for the specified key path.
  public static func keyPath<ValueType: Sendable & Equatable & Codable>(
    _ keyPath: any KeyPath<Model, ValueType> & Sendable
  ) -> UniqueKeyPath<Model, ValueType> {
    UniqueKeyPath(keyPath: keyPath)
  }
}
