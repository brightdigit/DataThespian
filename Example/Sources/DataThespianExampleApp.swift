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
  private static let databaseChangePublicist = DatabaseChangePublicist(    dbWatcher: DataMonitor.shared)
  // swiftlint:disable:next force_try
  private static let database = try! BackgroundDatabase(
    modelContainer: .init(for: Item.self),
    autosaveEnabled: true
  )

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
