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
      let parentModels = await database.fetch<Parent>(for: .all(Parent.self))
      let selectors = parentModels.map { Selector<Parent>.Get.model($0) }
      #expect(parentModels.count == 1)

      let parentIDs = await database.fetch(for: selectors) { $0.id }

      #expect(parentIDs.count == 1)
      #expect(parentIDs.first == parentID)

    #endif
  }
}
