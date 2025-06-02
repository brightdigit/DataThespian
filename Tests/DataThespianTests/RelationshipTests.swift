import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

internal struct RelationshipTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testParentChildRelationship() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childID = UUID()
      
      // Create a parent with a child
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        let child = Child(id: childID)
        parent.children?.append(child)
        context.insert(parent)
        try context.save()
      }
      
      // Verify the relationship is properly established
      let children = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(children?.count == 1)
      #expect(children?.first == childID)
      
      // Verify bidirectional relationship
      let parentFromChild = await database.fetch(for: .all(Child.self)) { children in
        children.first?.parent?.id
      }
      
      #expect(parentFromChild == parentID)
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testAddMultipleChildren() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childIDs = (0..<3).map { _ in UUID() }
      
      // Create a parent with multiple children
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        for childID in childIDs {
          let child = Child(id: childID)
          parent.children?.append(child)
        }
        context.insert(parent)
        try context.save()
      }
      
      // Verify all children are associated with the parent
      let retrievedChildIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(retrievedChildIDs?.count == 3)
      for childID in childIDs {
        #expect(retrievedChildIDs?.contains(childID) == true)
      }
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testRemoveChildFromParent() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childIDs = (0..<3).map { _ in UUID() }
      
      // Create a parent with multiple children
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        for childID in childIDs {
          let child = Child(id: childID)
          parent.children?.append(child)
        }
        context.insert(parent)
        try context.save()
      }
      
      // Remove one child from the parent
      try await database.withModelContext { context in
        let parents = try context.fetch(FetchDescriptor<Parent>())
        let parent = parents.first!
        let childToRemove = parent.children?.first { $0.id == childIDs[0] }
        if let index = parent.children?.firstIndex(where: { $0.id == childIDs[0] }) {
          parent.children?.remove(at: index)
        }
        try context.save()
      }
      
      // Verify the child was removed
      let remainingChildIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(remainingChildIDs?.count == 2)
      #expect(!remainingChildIDs!.contains(childIDs[0]))
      #expect(remainingChildIDs!.contains(childIDs[1]))
      #expect(remainingChildIDs!.contains(childIDs[2]))
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteParentCascade() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childIDs = (0..<3).map { _ in UUID() }
      
      // Create a parent with multiple children
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        for childID in childIDs {
          let child = Child(id: childID)
          parent.children?.append(child)
        }
        context.insert(parent)
        try context.save()
      }
      
      // Delete the parent
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        parent.id == parentID
      }))
      
      // Verify the children are orphaned or deleted based on the relationship configuration
      let orphanedChildren = await database.fetch(for: .all(Child.self)) { children in
        children.filter { $0.parent == nil }.map(\.id)
      }
      
      // Verify cascade behavior (this assertion may vary based on your cascade delete rules)
      #expect(orphanedChildren.count == 3)
    #endif
  }
}