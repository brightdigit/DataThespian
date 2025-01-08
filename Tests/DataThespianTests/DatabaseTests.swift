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
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
  }
}
