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

  internal struct NotificationDataUpdate: DatabaseChangeSet, Sendable {
    internal let inserted: Set<ManagedObjectMetadata>

    internal let deleted: Set<ManagedObjectMetadata>

    internal let updated: Set<ManagedObjectMetadata>

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

    private init(
      inserted: Set<ManagedObjectMetadata>,
      deleted: Set<ManagedObjectMetadata>,
      updated: Set<ManagedObjectMetadata>
    ) {
      self.inserted = inserted
      self.deleted = deleted
      self.updated = updated
    }

    internal init(_ notification: Notification) {
      self.init(
        inserted: notification.managedObjects(key: NSInsertedObjectsKey),
        deleted: notification.managedObjects(key: NSDeletedObjectsKey),
        updated: notification.managedObjects(key: NSUpdatedObjectsKey)
      )
    }
  }
#endif
