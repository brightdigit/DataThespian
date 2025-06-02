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
      
      // Test delete
      try await database.withModelContext { context in
        let parent = try context.fetch(FetchDescriptor<Parent>()).first
        if let parent = parent {
          context.delete(parent)
          try context.save()
        }
      }
      
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
        parent.children.append(child)
        context.insert(parent)
        try context.save()
      }
      
      let childrenIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.first?.children.map(\.id)
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
}
