import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct FetchTests {
  @Test internal func testFetchAll() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = [UUID(), UUID(), UUID()]

      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Fetch all parents
      let fetchedIDs = await database.fetch(for: .all(Parent.self)) { parents in
        parents.map(\.id)
      }

      #expect(fetchedIDs.sorted() == parentIDs.sorted())
    #endif
  }

  @Test internal func testFetchByID() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert a parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      // Fetch by ID
      let fetchedID = await database.getOptional(
        for: .predicate(#Predicate<Parent> { $0.id == parentID })
      ) { parent in
        parent?.id
      }

      #expect(fetchedID == parentID)
    #endif
  }

  @Test internal func testFetchByIDs() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = [UUID(), UUID(), UUID()]

      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Fetch by IDs
      let fetchedIDs = await database.fetch(
        for: .descriptor(predicate: #Predicate<Parent> { parentIDs.contains($0.id) })
      ) { parents in
        parents.map(\.id)
      }

      #expect(fetchedIDs.sorted() == parentIDs.sorted())
    #endif
  }

  @Test internal func testFetchByPredicate() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert a parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      // Fetch by predicate
      let fetchedID = await database.getOptional(
        for: .predicate(
          #Predicate<Parent> { parent in
            parent.id == parentID
          }
        )
      ) { parent in
        parent?.id
      }

      #expect(fetchedID == parentID)
    #endif
  }

  @Test internal func testFetchByValue() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert a parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      // Fetch by value
      let fetchedID = await database.getOptional(
        for: .predicate(#Predicate<Parent> { $0.id == parentID })
      ) { parent in
        parent?.id
      }

      #expect(fetchedID == parentID)
    #endif
  }

  @Test internal func testFetchByValues() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentIDs = [UUID(), UUID(), UUID()]

      // Insert multiple parents
      try await database.withModelContext { context in
        for id in parentIDs {
          context.insert(Parent(id: id))
        }
        try context.save()
      }

      // Fetch by values
      let fetchedIDs = await database.fetch(
        for: .descriptor(predicate: #Predicate<Parent> { parentIDs.contains($0.id) })
      ) { parents in
        parents.map(\.id)
      }

      #expect(fetchedIDs.sorted() == parentIDs.sorted())
    #endif
  }
}
