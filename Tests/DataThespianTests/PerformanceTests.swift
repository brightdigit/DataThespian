import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct PerformanceTests {
  @Test internal func testBulkInsertPerformance() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentCount = 1000
      let parentIDs = (0..<parentCount).map { _ in UUID() }
      
      // Measure bulk insert performance
      let startTime = Date()
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      let endTime = Date()
      
      // Verify all parents were inserted
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == parentCount)
      
      // Log performance metrics
      let duration = endTime.timeIntervalSince(startTime)
      print("Bulk insert of \(parentCount) parents took \(duration) seconds")
    #endif
  }

  @Test internal func testBulkDeletePerformance() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentCount = 1000
      let parentIDs = (0..<parentCount).map { _ in UUID() }
      
      // Insert parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      
      // Measure bulk delete performance
      let startTime = Date()
    try await database.delete(.predicate(
      #Predicate<Parent>{ parentIDs.contains($0.id)}
    ))
      let endTime = Date()
      
      // Verify all parents were deleted
      let count = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(count == 0)
      
      // Log performance metrics
      let duration = endTime.timeIntervalSince(startTime)
      print("Bulk delete of \(parentCount) parents took \(duration) seconds")
    #endif
  }

  @Test internal func testBulkFetchPerformance() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentCount = 1000
      let parentIDs = (0..<parentCount).map { _ in UUID() }
      
      // Insert parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }
      
      // Measure bulk fetch performance
      let startTime = Date()
      let fetchedIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }
      let endTime = Date()
      
      // Verify all parents were fetched
      #expect(fetchedIDs.count == parentCount)
      
      // Log performance metrics
      let duration = endTime.timeIntervalSince(startTime)
      print("Bulk fetch of \(parentCount) parents took \(duration) seconds")
    #endif
  }
} 
