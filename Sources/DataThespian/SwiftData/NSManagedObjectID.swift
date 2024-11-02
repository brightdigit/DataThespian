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
  private struct PersistentIdentifierJSON: Codable {
    private struct Implementation: Codable {
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

    private var implementation: Implementation

    private init(implementation: PersistentIdentifierJSON.Implementation) {
      self.implementation = implementation
    }

    fileprivate init(
      primaryKey: String,
      uriRepresentation: URL,
      isTemporary: Bool,
      storeIdentifier: String,
      entityName: String
    ) {
      self.init(
        implementation:
          .init(
            primaryKey: primaryKey,
            uriRepresentation: uriRepresentation,
            isTemporary: isTemporary,
            storeIdentifier: storeIdentifier,
            entityName: entityName
          )
      )
    }
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

    /// Compute PersistentIdentifier from NSManagedObjectID.
    ///
    /// - Returns: A PersistentIdentifier instance.
    /// - Throws: `PersistentIdentifierError`
    /// if the `storeIdentifier` or `entityName` properties are missing.
    public func persistentIdentifier() throws -> PersistentIdentifier {
      guard let storeIdentifier else {
        throw PersistentIdentifierError.missingProperty(.storeIdentifier)
      }
      guard let entityName else { throw PersistentIdentifierError.missingProperty(.entityName) }
      let json = PersistentIdentifierJSON(
        primaryKey: primaryKey,
        uriRepresentation: uriRepresentation(),
        isTemporary: isTemporaryID,
        storeIdentifier: storeIdentifier,
        entityName: entityName
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
    /// The primary key of the managed object, which is the last path component of the URI.
    public var primaryKey: String { uriRepresentation().lastPathComponent }

    /// The store identifier, which is the host of the URI.
    public var storeIdentifier: String? {
      guard let identifier = uriRepresentation().host() else {
        return nil
      }
      return identifier
    }

    /// The entity name, which is derived from the entity.
    public var entityName: String? {
      guard let entityName = entity.name else {
        return nil
      }
      return entityName
    }
  }
#endif
