//
//  NotFoundErrorTests.swift
//  DataThespian
//
//  Created for DataThespian.
//

import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct NotFoundErrorTests {
  @Test internal func testAnyModelNotFoundError() throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        // Create and save a parent
        let parent = Parent(id: UUID())
        context.insert(parent)
        try context.save()
        
        // Get a valid PersistentIdentifier
        let persistentID = parent.persistentModelID
        
        // Create a NotFoundError with the PersistentIdentifier
        let error = AnyModel.NotFoundError(persistentIdentifier: persistentID)
        
        // Verify the error contains the correct PersistentIdentifier
        #expect(error.persistentIdentifier.id == persistentID.id)
        
        // Create a NotFoundError with the same PersistentIdentifier for the typed Model
        let typedError = Model<Parent>.NotFoundError(persistentIdentifier: persistentID)
        
        #expect(error.persistentIdentifier.id == typedError.persistentIdentifier.id)
      }
    #endif
  }
}