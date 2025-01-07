import Testing
import Foundation
import SwiftData

@testable import DataThespian

@Model
class Parent {
  internal init(id: UUID) {
    self.id = id
  }
  
  var id: UUID
  
}

@Model
class Child {
  internal init(id: UUID) {
    self.id = id
  }
  
  var id: UUID
  var parent: Parent?
}


@ModelActor
actor TestingDatabase : Database {
  
  
}

extension TestingDatabase {
  init(for forTypes: any PersistentModel.Type...) throws {
    
    let container = try ModelContainer(for: .init(forTypes), configurations: .init(isStoredInMemoryOnly: true))
    self.init(modelContainer: container)
  }
}



@Test internal func withModelContext() async throws {
  let database = try TestingDatabase(for: Parent.self, Child.self)
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}
