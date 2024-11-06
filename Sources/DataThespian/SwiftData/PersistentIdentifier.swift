//
//  PersistentIdentifier.swift
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
  import SwiftData
  /// Returns the value of a child property of an object using reflection.
  ///
  /// - Parameters:
  ///   - object: The object to inspect.
  ///   - childName: The name of the child property to retrieve.
  /// - Returns: The value of the child property, or nil if it does not exist.
  private func getMirrorChildValue(of object: Any, childName: String) -> Any? {
    guard let child = Mirror(reflecting: object).children.first(where: { $0.label == childName })
    else {
      return nil
    }

    return child.value
  }

  // Extension to add computed properties for accessing underlying CoreData
  // implementation details of PersistentIdentifier
  extension PersistentIdentifier {
    // Private stored property to hold reference to underlying implementation
    private var mirrorImplementation: Any? {
      guard let implementation = getMirrorChildValue(of: self, childName: "implementation") else {
        assertionFailure("Should always be there.")
        return nil
      }
      return implementation
    }

    // Computed property to access managedObjectID from implementation
    private var objectID: NSManagedObjectID? {
      guard let mirrorImplementation,
        let objectID = getMirrorChildValue(of: mirrorImplementation, childName: "managedObjectID")
          as? NSManagedObjectID
      else {
        return nil
      }
      return objectID
    }

    // Computed property to access uriRepresentation from objectID
    private var uriRepresentation: URL? {
      objectID?.uriRepresentation()
    }

    // swiftlint:disable:next discouraged_optional_boolean
    internal var isTemporary: Bool? {
      guard let mirrorImplementation,
        let isTemporary = getMirrorChildValue(of: mirrorImplementation, childName: "isTemporary")
          as? Bool
      else {
        assertionFailure("Should always be there.")
        return nil
      }
      return isTemporary
    }
  }
#endif
