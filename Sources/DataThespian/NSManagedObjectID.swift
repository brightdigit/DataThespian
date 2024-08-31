//
// NSManagedObjectID.swift
// Copyright (c) 2024 BrightDigit.
//

//
//  Created by Yang Xu on 2023/8/23.
//

#if canImport(CoreData) && canImport(SwiftData)
    public import CoreData

    import Foundation

    public import SwiftData

    // Model to represent identifier implementation as JSON
    private struct PersistentIdentifierJSON: Codable {
        fileprivate struct Implementation: Codable {
            var primaryKey: String
            var uriRepresentation: URL
            var isTemporary: Bool
            var storeIdentifier: String
            var entityName: String
        }

        fileprivate var implementation: Implementation
    }

    public extension NSManagedObjectID {
        enum PersistentIdentifierError: Error {
            case decodingError(DecodingError)
            case encodingError(EncodingError)
            case missingProperty(Property)

            public enum Property: Sendable {
                case storeIdentifier
                case entityName
            }
        }

        // Compute PersistentIdentifier from NSManagedObjectID
        func persistentIdentifier() throws -> PersistentIdentifier {
            guard let storeIdentifier else {
                throw PersistentIdentifierError.missingProperty(.storeIdentifier)
            }
            guard let entityName else {
                throw PersistentIdentifierError.missingProperty(.entityName)
            }
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
            do {
                data = try encoder.encode(json)
            } catch let error as EncodingError {
                throw PersistentIdentifierError.encodingError(error)
            }
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(PersistentIdentifier.self, from: data)
            } catch let error as DecodingError {
                throw PersistentIdentifierError.decodingError(error)
            }
        }
    }

    // Extensions to expose needed implementation details
    extension NSManagedObjectID {
        // Primary key is last path component of URI
        var primaryKey: String {
            uriRepresentation().lastPathComponent
        }

        // Store identifier is host of URI
        var storeIdentifier: String? {
            guard let identifier = uriRepresentation().host() else {
                return nil
            }
            return identifier
        }

        // Entity name from entity name
        var entityName: String? {
            guard let entityName = entity.name else {
                return nil
            }
            return entityName
        }
    }
#endif
