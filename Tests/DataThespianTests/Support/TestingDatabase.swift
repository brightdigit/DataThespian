//
//  TestingDatabase.swift
//  DataThespian
//
//  Created by Leo Dion on 1/7/25.
//

#if canImport(SwiftData)
  @testable import DataThespian
  import SwiftData

  @ModelActor
  internal actor TestingDatabase: Database {
  }

  extension TestingDatabase {
    internal init(for forTypes: any PersistentModel.Type...) throws {
      let container = try ModelContainer(
        for: .init(forTypes),
        configurations: .init(isStoredInMemoryOnly: true)
      )
      self.init(modelContainer: container)
    }
  }
#endif
