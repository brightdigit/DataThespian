//
// ManagedObjectMetadata.swift
// Copyright (c) 2024 BrightDigit.
//



#if canImport(SwiftData)
@inlinable
internal func assertionFailure(error: any Error, file: StaticString = #file, line: UInt = #line) {
    assertionFailure(error.localizedDescription, file: file, line: line)
}

    public import SwiftData

    public struct ManagedObjectMetadata: Sendable, Hashable {
        public let entityName: String
        public let persistentIdentifier: PersistentIdentifier
        public init(entityName: String, persistentIdentifier: PersistentIdentifier) {
            self.entityName = entityName
            self.persistentIdentifier = persistentIdentifier
        }
    }

    #if canImport(CoreData)
        import CoreData

        extension ManagedObjectMetadata {
            init?(managedObject: NSManagedObject) {
                let persistentIdentifier: PersistentIdentifier
                do {
                    persistentIdentifier = try managedObject.objectID.persistentIdentifier()
                } catch {
                    assertionFailure(error: error)
                    return nil
                }
                self.init(
                    entityName: managedObject.entity.managedObjectClassName,
                    persistentIdentifier: persistentIdentifier
                )
            }
        }
    #endif
#endif
