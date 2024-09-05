//
// ModelContext.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
    import Foundation
    import SwiftData

extension ModelContext : Loggable {
  public static var loggingCategory: ThespianLogging.Category {
    .data
  }
        func existingModel<T>(
            for objectID: PersistentIdentifier
        ) throws -> T? where T: PersistentModel {
            if let registered: T = registeredModel(for: objectID) {
                return registered
            }
          
          if let notRegistered : T = model(for: objectID) as? T {
            return notRegistered
          }

            let fetchDescriptor = FetchDescriptor<T>(
                predicate: #Predicate {
                    $0.persistentModelID == objectID
                }
            )

            return try fetch(fetchDescriptor).first
        }
    }
#endif
