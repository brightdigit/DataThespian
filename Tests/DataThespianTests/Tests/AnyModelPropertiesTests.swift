//
//  AnyModelPropertiesTests.swift
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
internal struct AnyModelPropertiesTests {
  @Test internal func testIsTemporaryProperty() throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        // Create a parent model but don't save it yet - it should be temporary
        let unsavedParent = Parent(id: UUID())
        context.insert(unsavedParent)
        
        // Create an AnyModel from the unsaved parent
        let anyModelUnsaved = AnyModel(unsavedParent)
        
        // Verify isTemporary is true for unsaved model
        #expect(anyModelUnsaved.isTemporary == true)
        
        // Save the context and create a new parent
        try context.save()
        let savedParent = Parent(id: UUID())
        context.insert(savedParent)
        try context.save()
        
        // Create an AnyModel from the saved parent
        let anyModelSaved = AnyModel(savedParent)
        
        // Verify isTemporary is false for saved model
        #expect(anyModelSaved.isTemporary == false)
      }
    #endif
  }
}