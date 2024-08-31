//
// ModelContext.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
    import Foundation
    import SwiftData

    extension ModelContext {
        func existingModel<T>(
            for objectID: PersistentIdentifier
        ) throws -> T? where T: PersistentModel {
            if let registered: T = registeredModel(for: objectID) {
                return registered
            }

            assertionFailure("This first method should always work.")

            let fetchDescriptor = FetchDescriptor<T>(
                predicate: #Predicate {
                    $0.persistentModelID == objectID
                }
            )

            return try fetch(fetchDescriptor).first
        }
    }
#endif
