//
//  DatabaseChangeSet.swift
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
  /// A protocol that represents a set of changes to a database.
  public protocol DatabaseChangeSet: Sendable {
    /// The set of inserted managed object metadata.
    var inserted: Set<ManagedObjectMetadata> { get }

    /// The set of deleted managed object metadata.
    var deleted: Set<ManagedObjectMetadata> { get }

    /// The set of updated managed object metadata.
    var updated: Set<ManagedObjectMetadata> { get }
  }

  extension DatabaseChangeSet {
    /// A boolean value that indicates whether the change set is empty.
    public var isEmpty: Bool { inserted.isEmpty && deleted.isEmpty && updated.isEmpty }

    /// Checks whether the change set contains any changes of the specified types
    /// that match the provided entity names.
    ///
    /// - Parameters:
    ///   - types: The set of change types to check for. Defaults to `.all`.
    ///   - filteringEntityNames: The set of entity names to filter by.
    /// - Returns: `true` if the change set contains any changes of the specified types
    /// that match the provided entity names, `false` otherwise.
    public func update(
      of types: Set<DatabaseChangeType> = .all, contains filteringEntityNames: Set<String>
    ) -> Bool {
      let updateEntityNamesArray = types.flatMap { self[keyPath: $0.keyPath] }.map(\.entityName)
      let updateEntityNames = Set(updateEntityNamesArray)
      return !updateEntityNames.isDisjoint(with: filteringEntityNames)
    }
  }
#endif
