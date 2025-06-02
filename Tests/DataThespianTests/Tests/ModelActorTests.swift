import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct ModelActorTests {
  @Test internal func testGetOptionalWithModel() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert a parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }

      // Test getOptional with model selector
      let parentModels: [Model<Parent>]
      let parentIDs: [UUID]
      #if swift(>=6.1)
        parentModels = await database.fetch(for: .all(Parent.self))
      #else
        parentModels = await database.fetch<Parent>(for: .all(Parent.self))
      #endif

      let selectors = parentModels.map { Selector<Parent>.Get.model($0) }
      #expect(parentModels.count == 1)

      #if swift(>=6.1)
        parentIDs = await database.fetch(for: selectors) { $0.id }
      #else
        parentIDs = try await database.fetch<Parent>(for: selectors) { $0.id }
      #endif

      #expect(parentIDs.count == 1)
      #expect(parentIDs.first == parentID)

    #endif
  }
}
