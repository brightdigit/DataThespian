//
//  DataThespianExampleApp.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import DataThespian
import SwiftData
import SwiftUI

@main
internal struct DataThespianExampleApp: App {
  private static let databaseChangePublicist = DatabaseChangePublicist()

  private static let database = BackgroundDatabase {
    // swift-format-ignore: NeverUseForceTry
    // swiftlint:disable:next force_try
    try! ModelActorDatabase(modelContainer: ModelContainer(for: Item.self)) {
      let context = ModelContext($0)
      context.autosaveEnabled = true
      return context
    }
  }

  internal var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .database(Self.database)
    .environment(\.databaseChangePublicist, Self.databaseChangePublicist)
  }

  internal init() {
    DataMonitor.shared.begin(with: [])
  }
}
