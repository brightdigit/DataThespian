//
//  DatabaseConcurrencyTests.swift
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

internal struct DatabaseConcurrencyTests {
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentInserts() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let insertCount = 10
      
      // Perform concurrent inserts
      try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<insertCount {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        
        try await group.waitForAll()
      }
      
      // Verify all inserts were successful
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == insertCount)
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentDeletions() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = (0..<10).map { _ in UUID() }
      
      // Insert test data
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
      #expect(initialCount == 10)
      
      // Split IDs into two groups for concurrent deletion
      let firstHalf = Array(parentIDs.prefix(5))
      let secondHalf = Array(parentIDs.suffix(5))
      
      // Perform concurrent deletions
      try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            firstHalf.contains(parent.id)
          }))
        }
        
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            secondHalf.contains(parent.id)
          }))
        }
        
        try await group.waitForAll()
      }
      
      // Verify all items were deleted
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 0)
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentInsertAndDelete() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()
      
      // Insert initial item
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }
      
      // Verify initial state
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 1)
      
      // Perform concurrent insert and delete operations
      try await withThrowingTaskGroup(of: Void.self) { group in
        // Add 5 new items
        for _ in 0..<5 {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        
        // Delete the initial item
        group.addTask {
          try await database.delete(.predicate(#Predicate<Parent> { parent in
            parent.id == parentID
          }))
        }
        
        try await group.waitForAll()
      }
      
      // Verify final state
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 5)
      
      let finalIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }
      #expect(!finalIDs.contains(parentID))
    #endif
  }
  
  @Test(.enabled(if: swiftDataIsAvailable())) internal func testConcurrentOperationsPerformance() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let operationCount = 100
      
      let startTime = Date()
      
      // Perform a large number of concurrent operations
      try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<operationCount {
          group.addTask {
            try await database.withModelContext { context in
              context.insert(Parent(id: UUID()))
              try context.save()
            }
          }
        }
        try await group.waitForAll()
      }
      
      let duration = Date().timeIntervalSince(startTime)
      #expect(duration < 5.0, "Performance test failed, took too long: \(duration) seconds")
    #endif
  }
}