import Foundation
import Testing

@testable import DataThespian

#if canImport(SwiftData)
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct SelectorExtensionTests {
  @Test internal func testSelectorDeleteAllType() async throws {
    #if canImport(SwiftData)
      // Test that the .all(Type) extension method returns .all
      let selector = Selector<Parent>.Delete.all(Parent.self)
      
      // Use pattern matching to verify the case
      switch selector {
      case .all:
        // Test passes - selector is the .all case
        #expect(true)
      default:
        // Test fails - selector is not the .all case
        Issue.record("Expected .all case but got a different case")
      }
    #endif
  }
  
  @Test internal func testSelectorDeleteAllTypeUsage() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      
      // Verify we can call the method without error
      // This is mainly checking that the method signature is correct
      try await database.delete(.all(Parent.self))
      #expect(true, "Should be able to call delete with .all(Type)")
    #endif
  }
}
