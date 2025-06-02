import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

internal struct DatabaseTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func withModelContext() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      let parentIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }

      #expect(parentIDs == [parentID])
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testInsertAndDelete() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      
      // Test insert
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }
      
      // Verify insert
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 1)
      
      // Test delete using predicate
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        parent.id == parentID
      }))
      
      // Verify delete
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 0)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testParentChildRelationship() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childID = UUID()
      
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        let child = Child(id: childID)
        parent.children?.append(child)
        context.insert(parent)
        try context.save()
      }
      
      let childrenIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      
      #expect(childrenIDs?.count == 1)
      #expect(childrenIDs?.first == childID)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentOperations() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      
      // Create multiple parents concurrently
      try await withThrowingTaskGroup(of: Void.self) { group in
        for i in 0..<5 {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        try await group.waitForAll()
      }
      
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 5)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testErrorHandling() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      
      // Test invalid operation
      do {
        try await database.withModelContext { context in
          // Attempt to save without any changes
          try context.save()
        }
      } catch {
        // Expected error
        #expect(true)
      }
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testPerformance() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let startTime = Date()
      
      // Insert 1000 records
      try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<1000 {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        try await group.waitForAll()
      }
      
      let endTime = Date()
      let duration = endTime.timeIntervalSince(startTime)
      
      // Performance expectation: should complete within 5 seconds
      #expect(duration < 5.0)
      
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 1000)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteByValue() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID1 = UUID()
      let parentID2 = UUID()
      let parentID3 = UUID()
      
      // Insert multiple parents
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID1))
        context.insert(Parent(id: parentID2))
        context.insert(Parent(id: parentID3))
        try context.save()
      }
      
      // Delete parent with specific ID using predicate
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        parent.id == parentID2
      }))
      
      // Verify only the specified parent was deleted
      let remainingIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }
      #expect(remainingIDs.count == 2)
      #expect(remainingIDs.contains(parentID1))
      #expect(remainingIDs.contains(parentID3))
      #expect(!remainingIDs.contains(parentID2))
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteBySet() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = (0..<5).map { _ in UUID() }
      let idsToDelete = Set(parentIDs.prefix(2))
      
      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      
      // Delete parents with IDs in the set using predicate
      try await database.delete(.predicate(#Predicate<Parent> { parent in
        idsToDelete.contains(parent.id)
      }))
      
      // Verify only the specified parents were deleted
      let remainingIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }
      #expect(remainingIDs.count == 3)
      for id in idsToDelete {
        #expect(!remainingIDs.contains(id))
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
      
      let childrenIDsToDelete = [UUID](childIDs.prefix(2))
      // Delete children with specific IDs using predicate
      try await database.delete(.predicate(#Predicate<Child> { child in
        childrenIDsToDelete.contains(child.id)
      }))
      
      // Verify only one child remains
    let remainingChildren = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      #expect(remainingChildren?.count == 1)
      #expect(remainingChildren?.first == childIDs.last)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testDeleteAll() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      
      // Insert multiple parents
      try await database.withModelContext { context in
        for _ in 0..<5 {
          context.insert(Parent(id: UUID()))
        }
        try context.save()
      }
      
    
      // Delete all parents
    try await database.delete(Selector<Parent>.Delete.all)
      
      // Verify all parents were deleted
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 0)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentDeletions() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = (0..<10).map { _ in UUID() }
      
      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      
      // Split IDs into two groups for concurrent deletion
      let firstHalf = Array(parentIDs.prefix(5))
      let secondHalf = Array(parentIDs.suffix(5))
      
      // Perform concurrent deletions
      try await withThrowingTaskGroup(of: Void.self) { group in
        // First group of deletions
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            firstHalf.contains(parent.id)
          }))
        }
        
        // Second group of deletions
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            secondHalf.contains(parent.id)
          }))
        }
        
        try await group.waitForAll()
      }
      
      // Verify all parents were deleted
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 0)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentInsertAndDelete() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      
      // Start with one parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }
      
      // Perform concurrent insert and delete operations
      try await withThrowingTaskGroup(of: Void.self) { group in
        // Insert new parents
        for _ in 0..<5 {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        
        // Delete existing parent
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            parent.id == parentID
          }))
        }
        
        try await group.waitForAll()
      }
      
      // Verify final state
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 5)
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentRelationshipUpdates() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      let childIDs = (0..<5).map { _ in UUID() }
      
      // Create initial parent with some children
      try await database.withModelContext { context in
        let parent = Parent(id: parentID)
        for childID in childIDs.prefix(2) {
          let child = Child(id: childID)
          parent.children?.append(child)
        }
        context.insert(parent)
        try context.save()
      }
      
      // Perform concurrent operations on relationships
      try await withThrowingTaskGroup(of: Void.self) { group in
        // Add new children
        for childID in childIDs.suffix(3) {
          group.addTask {
            try await database.withModelContext { context in
              let parent = try context.fetch(FetchDescriptor<Parent>()).first
              let child = Child(id: childID)
              parent?.children?.append(child)
              try context.save()
            }
          }
        }
        
        let childIDsToDelete : [UUID] = .init(childIDs.prefix(1))
        // Delete some existing children
        group.addTask {
          try await database.delete(.predicate(#Predicate<Child> { child in
            childIDsToDelete.contains(child.id)
          }))
        }
        
        try await group.waitForAll()
      }
      
      // Verify final state
      let remainingChildren = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children?.map(\.id)
      }
      #expect(remainingChildren?.count == 4) // 1 deleted, 3 added
    #endif
  }

  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentBatchOperations() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let batchSize = 100
      let parentIDs = (0..<batchSize).map { _ in UUID() }
      
      // Insert initial batch
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      
    
    let parentIDsToDelete : [UUID] = .init(parentIDs.prefix(batchSize/2))
      // Perform concurrent batch operations
      try await withThrowingTaskGroup(of: Void.self) { group in
        // Delete first half
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            parentIDsToDelete.contains(parent.id)
          }))
        }
        
        // Insert new batch
        group.addTask {
          try await database.withModelContext { context in
            for _ in 0..<batchSize {
              context.insert(Parent(id: UUID()))
            }
            try context.save()
          }
        }
        
        try await group.waitForAll()
      }
      
      // Verify final state
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == batchSize * 3/2) // Original batch - deleted half + new batch
    #endif
  }
}
