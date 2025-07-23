import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct DeleteTests {
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

      // Verify initial count
      let initialCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(initialCount == 5)

      // Delete all parents using the new .all(Type) method
      try await database.delete(.all(Parent.self))

      // Verify all parents were deleted
      let parentCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(parentCount == 0)
    #endif
  }

  @Test internal func testDeleteAllWithMultipleEntityTypes() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)

      // Insert multiple parents and children
      try await database.withModelContext { context in
        // Add parents
        for _ in 0..<3 {
          context.insert(Parent(id: UUID()))
        }

        // Add children
        for _ in 0..<4 {
          context.insert(Child(id: UUID()))
        }

        try context.save()
      }

      // Verify initial counts
      let initialParentCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      let initialChildCount = await database.fetch(for: .all(Child.self)) { children in
        children.count
      }
      #expect(initialParentCount == 3)
      #expect(initialChildCount == 4)

      // Delete all parents using the new .all(Type) method
      try await database.delete(.all(Parent.self))

      // Verify only parents were deleted, not children
      let parentCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      let childCount = await database.fetch(for: .all(Child.self)) { children in
        children.count
      }
      #expect(parentCount == 0)
      #expect(childCount == 4)
    #endif
  }

  @Test internal func testDeleteAllWithRelationships() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)

      // Insert parents with children
      try await database.withModelContext { context in
        for _ in 0..<3 {
          let parent = Parent(id: UUID())

          // Add some children to each parent
          for _ in 0..<2 {
            let child = Child(id: UUID())
            child.parent = parent
            parent.children?.append(child)
            context.insert(child)
          }

          context.insert(parent)
        }

        try context.save()
      }

      // Delete all parents using the new .all(Type) method
      try await database.delete(.all(Parent.self))

      // Verify parents were deleted, and check remaining children
      let parentCount = await database.fetch(for: .all(Parent.self)) { parents in
        parents.count
      }
      #expect(parentCount == 0)
    #endif
  }

  @Test internal func testFetchModelAfterDelete() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = (0..<5).map { _ in UUID() }

      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Fetch their Model representations
      let models = await database.fetch(for: .all(Parent.self))
      #expect(models.count == parentIDs.count)
    

      // Delete all parents
      try await database.delete(.all(Parent.self))

      // Try to fetch a property for each deleted model
      for model in models {
        let result = await database.getOptional(for: .model(model)) { parent -> UUID? in
          guard let parent else {
            return nil
          }
          return parent.id
        }
        #expect(result == nil)
      }
    #endif
  }
}
