//
//  NSManagedObjectID.swift
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
  public import CoreData

  import Foundation

  public import SwiftData

  // periphery:ignore
  fileprivate struct PersistentIdentifierJSON: Codable {
    fileprivate struct Implementation: Codable {
      fileprivate init(
        primaryKey: String,
        uriRepresentation: URL,
        isTemporary: Bool,
        storeIdentifier: String,
        entityName: String
      ) {
        self.primaryKey = primaryKey
        self.uriRepresentation = uriRepresentation
        self.isTemporary = isTemporary
        self.storeIdentifier = storeIdentifier
        self.entityName = entityName
      }
      private var primaryKey: String
      private var uriRepresentation: URL
      private var isTemporary: Bool
      private var storeIdentifier: String
      private var entityName: String
    }

    fileprivate var implementation: Implementation
  }

  extension NSManagedObjectID {
    public enum PersistentIdentifierError: Error {
      case decodingError(DecodingError)
      case encodingError(EncodingError)
      case missingProperty(Property)

      public enum Property: Sendable {
        case storeIdentifier
        case entityName
      }
    }

    // Compute PersistentIdentifier from NSManagedObjectID
    public func persistentIdentifier() throws -> PersistentIdentifier {
      guard let storeIdentifier else {
        throw PersistentIdentifierError.missingProperty(.storeIdentifier)
      }
      guard let entityName else { throw PersistentIdentifierError.missingProperty(.entityName) }
      let json = PersistentIdentifierJSON(
        implementation: .init(
          primaryKey: primaryKey,
          uriRepresentation: uriRepresentation(),
          isTemporary: isTemporaryID,
          storeIdentifier: storeIdentifier,
          entityName: entityName
        )
      )
      let encoder = JSONEncoder()
      let data: Data
      do { data = try encoder.encode(json) } catch let error as EncodingError {
        throw PersistentIdentifierError.encodingError(error)
      }
      let decoder = JSONDecoder()
      do { return try decoder.decode(PersistentIdentifier.self, from: data) } catch let error
        as DecodingError
      { throw PersistentIdentifierError.decodingError(error) }
    }
  }

  // Extensions to expose needed implementation details
  extension NSManagedObjectID {
    // Primary key is last path component of URI
    var primaryKey: String { uriRepresentation().lastPathComponent }

    // Store identifier is host of URI
    var storeIdentifier: String? {
      guard let identifier = uriRepresentation().host() else { return nil }
      return identifier
    }

    // Entity name from entity name
    var entityName: String? {
      guard let entityName = entity.name else { return nil }
      return entityName
    }
  }
#endif
