//
//  NotificationDataUpdate.swift
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

#if canImport(CoreData) && canImport(SwiftData)
  import CoreData
  import Foundation
  /// Represents a set of changes to managed objects in a Core Data store.
  internal struct NotificationDataUpdate: DatabaseChangeSet, Sendable {
    /// The set of managed objects that were inserted.
    internal let inserted: Set<ManagedObjectMetadata>

    /// The set of managed objects that were deleted.
    internal let deleted: Set<ManagedObjectMetadata>

    /// The set of managed objects that were updated.
    internal let updated: Set<ManagedObjectMetadata>

    /// Initializes a `NotificationDataUpdate` instance with the specified sets
    /// of inserted, deleted, and updated managed objects.
    ///
    /// - Parameters:
    ///   - inserted: The set of managed objects that were inserted, or an empty set if none were inserted.
    ///   - deleted: The set of managed objects that were deleted, or an empty set if none were deleted.
    ///   - updated: The set of managed objects that were updated, or an empty set if none were updated.
    private init(
      inserted: Set<ManagedObjectMetadata>?,
      deleted: Set<ManagedObjectMetadata>?,
      updated: Set<ManagedObjectMetadata>?
    ) {
      self.init(
        inserted: inserted ?? .init(),
        deleted: deleted ?? .init(),
        updated: updated ?? .init()
      )
    }

    /// Initializes a `NotificationDataUpdate` instance with
    /// the specified sets of inserted, deleted, and updated managed objects.
    ///
    /// - Parameters:
    ///   - inserted: The set of managed objects that were inserted.
    ///   - deleted: The set of managed objects that were deleted.
    ///   - updated: The set of managed objects that were updated.
    private init(
      inserted: Set<ManagedObjectMetadata>,
      deleted: Set<ManagedObjectMetadata>,
      updated: Set<ManagedObjectMetadata>
    ) {
      self.inserted = inserted
      self.deleted = deleted
      self.updated = updated
    }

    /// Initializes a `NotificationDataUpdate` instance from a Notification object.
    ///
    /// - Parameter notification: The notification that triggered the data update.
    internal init(_ notification: Notification) {
      self.init(
        inserted: notification.managedObjects(key: NSInsertedObjectsKey),
        deleted: notification.managedObjects(key: NSDeletedObjectsKey),
        updated: notification.managedObjects(key: NSUpdatedObjectsKey)
      )
    }
  }
#endif
