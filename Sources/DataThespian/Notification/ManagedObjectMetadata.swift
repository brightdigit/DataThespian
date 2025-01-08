//
//  ManagedObjectMetadata.swift
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

#if canImport(SwiftData)
  public import SwiftData
  /// A struct that holds metadata about a managed object.
  public struct ManagedObjectMetadata: Sendable, Hashable {
    /// The name of the entity associated with the managed object.
    public let entityName: String
    /// The persistent identifier of the managed object.
    public let persistentIdentifier: PersistentIdentifier

    /// Initializes a `ManagedObjectMetadata` instance
    /// with the provided entity name and persistent identifier.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity associated with the managed object.
    ///   - persistentIdentifier: The persistent identifier of the managed object.
    public init(entityName: String, persistentIdentifier: PersistentIdentifier) {
      self.entityName = entityName
      self.persistentIdentifier = persistentIdentifier
    }
  }

  #if canImport(CoreData)
    import CoreData

    extension ManagedObjectMetadata {
      /// Initializes a `ManagedObjectMetadata` instance with the provided `NSManagedObject`.
      ///
      /// - Parameter managedObject: The `NSManagedObject` instance to get the metadata from.
      internal init?(managedObject: NSManagedObject) {
        let persistentIdentifier: PersistentIdentifier
        do {
          persistentIdentifier = try managedObject.objectID.persistentIdentifier()
        } catch {
          assertionFailure(error: error)
          return nil
        }

        guard let entityName = managedObject.entity.name else {
          assertionFailure("Missing entity name.")
          return nil
        }

        self.init(entityName: entityName, persistentIdentifier: persistentIdentifier)
      }
    }
  #endif
#endif
