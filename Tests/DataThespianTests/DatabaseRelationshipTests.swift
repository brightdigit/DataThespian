//
//  DatabaseRelationshipTests.swift
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

internal struct DatabaseRelationshipTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testParentChildRelationship() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childID = UUID()
      
      // Create parent with a child
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        let child = Child(id: childID)
        parent.children?.append(child)
        context.insert(parent)
        try context.save()
      }
      
      // Verify parent has the child
      let childrenIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(childrenIDs?.count == 1)
      #expect(childrenIDs?.first == childID)
      
      // Verify child has the parent
      let parentIDFromChild = await database.fetch(for: .all(Child.self)) { children in
        children.first?.parent?.id
      }
      
      #expect(parentIDFromChild == parentID)
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testMultipleChildrenRelationship() async throws {
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
      
      // Verify parent has all children
      let retrievedChildIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(retrievedChildIDs?.count == 3)
      for childID in childIDs {
        #expect(retrievedChildIDs?.contains(childID) == true)
      }
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentRelationshipUpdates() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      
      // Create initial parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }
      
      // Add children concurrently
      let childCount = 5
      try await withThrowingTaskGroup(of: Void.self) { group in
        for i in 0..<childCount {
          group.addTask {
            try await database.withModelContext { context in
              let parent = try context.fetch(FetchDescriptor<Parent>()).first
              let child = Child(id: UUID())
              parent?.children?.append(child)
              try context.save()
            }
          }
        }
        try await group.waitForAll()
      }
      
      // Verify all children were added
      let finalChildCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.count ?? 0
      }
      #expect(finalChildCount == childCount)
    #endif
  }
}