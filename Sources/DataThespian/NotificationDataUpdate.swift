//
// NotificationDataUpdate.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(CoreData) && canImport(SwiftData)
    import CoreData

    import Foundation

    struct NotificationDataUpdate: DatabaseChangeSet, Sendable {
        let inserted: Set<ManagedObjectMetadata>

        let deleted: Set<ManagedObjectMetadata>

        let updated: Set<ManagedObjectMetadata>

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

        init(_ notification: Notification) {
            self.init(
                inserted: notification.managedObjects(key: NSInsertedObjectsKey),
                deleted: notification.managedObjects(key: NSDeletedObjectsKey),
                updated: notification.managedObjects(key: NSUpdatedObjectsKey)
            )
        }
    }
#endif
