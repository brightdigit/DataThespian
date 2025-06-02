//
//  DatabaseDeletionTests.swift
//  DataThespian
//
//  Created by Unit Tests
//

import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

internal struct DatabaseDeletionTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteWithPredicate() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert test data
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      // Verify initial state
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 1)

      // Delete using predicate
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        parent.id == parentID
      }))

      // Verify deletion was successful
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 0)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteAll() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)

      // Insert multiple items
      try await database.withModelContext { context in
        for _ in 0..<5 {
          context.insert(Parent(id: UUID()))
        }
        try context.save()
      }

      // Verify initial state
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 5)

      // Delete all items
      try await database.delete(Selector<Parent>.Delete.all)

      // Verify all items were deleted
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 0)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteBySet() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = (0..<5).map { _ in UUID() }
      let idsToDelete = Set(parentIDs.prefix(3))

      // Insert multiple items
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Verify initial state
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 5)

      // Delete items with IDs in the set
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        idsToDelete.contains(parent.id)
      }))

      // Verify only specified items were deleted
      let remainingIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }
      #expect(remainingIDs.count == 2)
      
      for id in idsToDelete {
        #expect(!remainingIDs.contains(id))
      }
      
      for id in parentIDs where !idsToDelete.contains(id) {
        #expect(remainingIDs.contains(id))
      }
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteWithRelationships() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childIDs = (0..<3).map { _ in UUID() }

      // Create parent with multiple children
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        for childID in childIDs {
          let child = Child(id: childID)
          parent.children?.append(child)
        }
        context.insert(parent)
        try context.save()
      }

      // Verify initial state
      let initialChildrenCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.count ?? 0
      }
      #expect(initialChildrenCount == 3)

      // Delete one child
      let childIDToDelete = childIDs[0]
      try await database.delete(.predicate(#Predicate<Child> { child in
        child.id == childIDToDelete
      }))

      // Verify only specified child was deleted
      let remainingChildren = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      #expect(remainingChildren?.count == 2)
      #expect(!remainingChildren!.contains(childIDToDelete))
      #expect(remainingChildren!.contains(childIDs[1]))
      #expect(remainingChildren!.contains(childIDs[2]))
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteNonExistentItems() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)

      // Add some initial items
      let existingIDs = (0..<3).map { _ in UUID() }
      try await database.withModelContext { context in
        for id in existingIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Verify initial state
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 3)

      // Try to delete a non-existent item
      let nonExistentID = UUID()
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        parent.id == nonExistentID
      }))

      // Verify count remains the same
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 3)
    #endif
  }
}