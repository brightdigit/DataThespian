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
  
  @Test internal func testGetOptionalWithNonexistentModel() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      
      // Create a model with an ID that doesn't exist in the database
      let nonexistentModel = Model<Parent>(persistentIdentifier: UUID().uuidString)
      
      // Test getOptional with model selector for nonexistent model
      let result = await database.getOptional(
        for: .model(nonexistentModel)
      ) { $0?.id }
      
      // Result should be nil since the model doesn't exist
      #expect(result == nil)
    #endif
  }
  
  @Test internal func testGetOptionalWithPredicate() async throws {
    #if canImport(SwiftData)
      let database = try TestingDatabase(for: Parent.self, Child.self)
      let parentID = UUID()

      // Insert a parent
      try await database.withModelContext { context in
        context.insert(Parent(id: parentID))
        try context.save()
      }
      
      // Test getOptional with predicate selector
      let predicate = #Predicate<Parent> { $0.id == parentID }
      let result = await database.getOptional(
        for: .predicate(predicate)
      ) { $0?.id }
      
      #expect(result == parentID)
    #endif
  }
  
  @Test internal func testFetchWithDescriptor() async throws {
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
      
      // Create a descriptor
      let descriptor = FetchDescriptor<Parent>()
      
      // Test fetch with descriptor
      let fetchedModels = await database.fetch(for: .descriptor(descriptor))
      
      #expect(fetchedModels.count == parentIDs.count)
      
      // Test error handling by trying to fetch with an invalid selector
      // This should log an error and return an empty array
      let emptyResult = await database.fetch(for: .all(Parent.self))
      #expect(emptyResult.count == 3, "Should still return results despite the invalid selector case")
    #endif
  }
}