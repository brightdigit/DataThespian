//import Foundation
//import Testing
//
//@testable import DataThespian
//
//#if canImport(SwiftData)
//  import SwiftData
//#endif
//
//@Suite(.enabled(if: swiftDataIsAvailable()))
//internal struct BasicDatabaseTests {
//  @Test internal func withModelContext() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let parentID = UUID()
//      try await database.withModelContext { context in
//        context.insert(Parent(id: parentID))
//        try context.save()
//      }
//
//      let parentIDs = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.map(\.id)
//      }
//
//      #expect(parentIDs == [parentID])
//    #endif
//  }
//
//  @Test internal func testInsertAndDelete() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let parentID = UUID()
//      
//      // Test insert
//      try await database.withModelContext { context in
//        context.insert(Parent(id: parentID))
//        try context.save()
//      }
//      
//      // Verify insert
//      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(initialCount == 1)
//      
//      // Test delete using predicate
//      try await database.delete(.predicate(#Predicate<Parent> { parent in
//        parent.id == parentID
//      }))
//      
//      // Verify delete
//      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(finalCount == 0)
//    #endif
//  }
//
//  @Test internal func testDeleteAll() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      
//      // Insert multiple parents
//      try await database.withModelContext { context in
//        for _ in 0..<5 {
//          context.insert(Parent(id: UUID()))
//        }
//        try context.save()
//      }
//      
//      // Delete all parents
//    try await database.delete(Selector<Parent>.Delete.all)
//
//      // Verify all parents were deleted
//      let count = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(count == 0)
//    #endif
//  }
//}
//
//@Suite(.enabled(if: swiftDataIsAvailable()))
//internal struct ConcurrentDatabaseTests {
//  @Test internal func testConcurrentDeletions() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let parentIDs = (0..<10).map { _ in UUID() }
//      
//      // Insert multiple parents
//      try await database.withModelContext { context in
//        for id in parentIDs {
//          context.insert(Parent(id: id))
//        }
//        try context.save()
//      }
//      
//      // Split IDs into two groups for concurrent deletion
//      let firstHalf = Array(parentIDs.prefix(5))
//      let secondHalf = Array(parentIDs.suffix(5))
//      
//      // Perform concurrent deletions
//      try await withThrowingTaskGroup(of: Void.self) { group in
//        // First group of deletions
//        group.addTask {
//          try await database.delete(.predicate(#Predicate<Parent> { parent in
//            firstHalf.contains(parent.id)
//          }))
//        }
//        
//        // Second group of deletions
//        group.addTask {
//          try await database.delete(.predicate(#Predicate<Parent> { parent in
//            secondHalf.contains(parent.id)
//          }))
//        }
//        
//        try await group.waitForAll()
//      }
//      
//      // Verify all parents were deleted
//      let count = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(count == 0)
//    #endif
//  }
//
//  @Test internal func testConcurrentInsertAndDelete() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let parentID = UUID()
//      
//      // Start with one parent
//      try await database.withModelContext { context in
//        context.insert(Parent(id: parentID))
//        try context.save()
//      }
//      
//      // Perform concurrent insert and delete operations
//      try await withThrowingTaskGroup(of: Void.self) { group in
//        // Insert new parents
//        for _ in 0..<5 {
//          group.addTask {
//            try await database.withModelContext { context in
//              context.insert(Parent(id: UUID()))
//              try context.save()
//            }
//          }
//        }
//        
//        // Delete existing parent
//        group.addTask {
//          try await database.delete(.predicate(#Predicate<Parent> { parent in
//            parent.id == parentID
//          }))
//        }
//        
//        try await group.waitForAll()
//      }
//      
//      // Verify final state
//      let count = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(count == 5)
//    #endif
//  }
//
//  @Test internal func testConcurrentBatchOperations() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let batchSize = 100
//      let parentIDs = (0..<batchSize).map { _ in UUID() }
//      
//      // Insert initial batch
//      try await database.withModelContext { context in
//        for id in parentIDs {
//          context.insert(Parent(id: id))
//        }
//        try context.save()
//      }
//      
//      let parentIDsToDelete: [UUID] = .init(parentIDs.prefix(batchSize / 2))
//      // Perform concurrent batch operations
//      try await withThrowingTaskGroup(of: Void.self) { group in
//        // Delete first half
//        group.addTask {
//          try await database.delete(.predicate(#Predicate<Parent> { parent in
//            parentIDsToDelete.contains(parent.id)
//          }))
//        }
//        
//        // Insert new batch
//        group.addTask {
//          try await database.withModelContext { context in
//            for _ in 0..<batchSize {
//              context.insert(Parent(id: UUID()))
//            }
//            try context.save()
//          }
//        }
//        
//        try await group.waitForAll()
//      }
//      
//      // Verify final state
//      let count = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(count == batchSize * 3 / 2) // Original batch - deleted half + new batch
//    #endif
//  }
//}
//
//@Suite(.enabled(if: swiftDataIsAvailable()))
//internal struct RelationshipDatabaseTests {
//  @Test internal func testConcurrentRelationshipUpdates() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      let parentID = UUID()
//      let childIDs = (0..<5).map { _ in UUID() }
//      
//      // Create initial parent with some children
//      try await database.withModelContext { context in
//        let parent = Parent(id: parentID)
//        for childID in childIDs.prefix(2) {
//          let child = Child(id: childID)
//          parent.children?.append(child)
//        }
//        context.insert(parent)
//        try context.save()
//      }
//      
//      // Perform concurrent operations on relationships
//      try await withThrowingTaskGroup(of: Void.self) { group in
//        // Add new children
//        for childID in childIDs.suffix(3) {
//          group.addTask {
//            try await database.withModelContext { context in
//              let parent = try context.fetch(FetchDescriptor<Parent>()).first
//              let child = Child(id: childID)
//              parent?.children?.append(child)
//              try context.save()
//            }
//          }
//        }
//        
//        // Delete some existing children
//        let childIDsToDelete: [UUID] = .init(childIDs.prefix(1))
//        group.addTask {
//          try await database.delete(.predicate(#Predicate<Child> { child in
//            childIDsToDelete.contains(child.id)
//          }))
//        }
//        
//        try await group.waitForAll()
//      }
//      
//      // Verify final state
//      let remainingChildren = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.first?.children?.map(\.id)
//      }
//      #expect(remainingChildren?.count == 4) // 1 deleted, 3 added
//    #endif
//  }
//}
//
//@Suite(.enabled(if: swiftDataIsAvailable()))
//internal struct ErrorHandlingDatabaseTests {
//  @Test internal func testErrorHandling() async throws {
//    #if canImport(SwiftData)
//      let database = try TestingDatabase(for: Parent.self, Child.self)
//      
//      // Add some initial rows
//      let existingIDs = (0..<3).map { _ in UUID() }
//      try await database.withModelContext { context in
//        for id in existingIDs {
//          context.insert(Parent(id: id))
//        }
//        try context.save()
//      }
//      
//      // Verify initial state
//      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(initialCount == 3)
//      
//      // Try to delete a non-existent parent
//      let nonExistentID = UUID()
//      try await database.delete(.predicate(#Predicate<Parent> { parent in
//        parent.id == nonExistentID
//      }))
//      try await database.save()
//      
//      // Verify state after deleting non-existent row
//      let countAfterSingleDelete = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(countAfterSingleDelete == 3)
//      
//      // Try to delete multiple non-existent parents
//      let nonExistentIDs = (0..<5).map { _ in UUID() }
//      try await database.delete(.predicate(#Predicate<Parent> { parent in
//        nonExistentIDs.contains(parent.id)
//      }))
//      try await database.save()
//      
//      // Verify state after deleting multiple non-existent rows
//      let countAfterMultipleDelete = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(countAfterMultipleDelete == 3)
//      
//      // Verify we can still delete existing rows
//      try await database.delete(.predicate(#Predicate<Parent> { parent in
//        existingIDs.contains(parent.id)
//      }))
//      try await database.save()
//      
//      // Verify final state
//      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
//        parents.count
//      }
//      #expect(finalCount == 0)
//    #endif
//  }
//}
