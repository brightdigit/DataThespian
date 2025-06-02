//
//  AnyModelTests.swift
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
internal struct AnyModelTests {
  @Test internal func testAnyModelInitWithPersistentIdentifier() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        // Create and save a parent to get a valid PersistentIdentifier
        let parent = Parent(id: UUID())
        context.insert(parent)
        try context.save()

        // Create an AnyModel with the parent's PersistentIdentifier
        let persistentID = parent.persistentModelID
        let anyModel = AnyModel(persistentIdentifier: persistentID)

        // Verify the AnyModel has the correct persistentIdentifier
        #expect(anyModel.persistentIdentifier.id == persistentID.id)
      }
    #endif
  }

  @Test internal func testAnyModelInitWithPersistentModel() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        // Create and save a parent
        let parent = Parent(id: UUID())
        context.insert(parent)
        try context.save()

        // Create an AnyModel from the parent
        let anyModel = AnyModel(parent)

        // Verify the AnyModel has the correct persistentIdentifier
        #expect(anyModel.persistentIdentifier.id == parent.persistentModelID.id)
      }
    #endif
  }

  @Test internal func testTypeErasureFromModel() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        // Create and save a parent
        let parent = Parent(id: UUID())
        context.insert(parent)
        try context.save()

        // Create a typed Model from the parent
        let typedModel = Model(parent)

        // Type erase the Model to AnyModel
        let anyModel = AnyModel(typeErase: typedModel)

        // Verify the AnyModel has the correct persistentIdentifier
        #expect(anyModel.persistentIdentifier.id == typedModel.persistentIdentifier.id)
      }
    #endif
  }

  @Test internal func testCreateTypedModelFromAnyModel() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      try await database.withModelContext { context in
        let parent = Parent(id: UUID())
        context.insert(parent)
        try context.save()

        let anyModel = AnyModel(parent)
        let typedModel = Model(anyModel: anyModel, type: Parent.self)

        #expect(typedModel.persistentIdentifier.id == anyModel.persistentIdentifier.id)
      }
    #endif
  }
}
