//
//  DatabaseChangeType.swift
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

/// An enumeration that represents the different types of changes that can occur in a database.
public enum DatabaseChangeType: CaseIterable, Sendable {
  /// Represents an insertion of a new record in the database.
  case inserted
  /// Represents a deletion of a record in the database.
  case deleted
  /// Represents an update to an existing record in the database.
  case updated

  #if canImport(SwiftData)
    /// The key path associated with the current change type.
    internal var keyPath: KeyPath<any DatabaseChangeSet, Set<ManagedObjectMetadata>> {
      switch self {
      case .inserted:
        return \.inserted
      case .deleted:
        return \.deleted
      case .updated:
        return \.updated
      }
    }
  #endif
}

/// An extension to `Set` where the `Element` is `DatabaseChangeType`.
extension Set where Element == DatabaseChangeType {
  /// A static property that represents a set containing all `DatabaseChangeType` cases.
  public static let all: Self = .init(DatabaseChangeType.allCases)
}
