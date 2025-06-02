import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct BasicDatabaseTests {
  @Test internal func withModelContext() async throws {
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

  @Test internal func testInsertAndDelete() async throws {
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
      try await database.delete(
        .predicate(
          #Predicate<Parent> { parent in
            parent.id == parentID
          }
        )
      )

      // Verify delete
      let finalCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(finalCount == 0)
    #endif
  }

  @Test internal func testDeleteAll() async throws {
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
      try await database.delete(.all(Parent.self))

      // Verify all parents were deleted
      let parentCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(parentCount == 0)
    #endif
  }
}
