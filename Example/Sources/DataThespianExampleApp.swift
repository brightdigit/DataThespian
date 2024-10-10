//
//  DataThespianExampleApp.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import SwiftUI
import SwiftData
import DataThespian

@main
struct DataThespianExampleApp: App {
  private static let databaseChangePublicist = DatabaseChangePublicist(dbWatcher: DataMonitor.shared)
  private static let database = try! BackgroundDatabase(modelContainer: .init(for: Item.self), autosaveEnabled: true)
  
  init () {
    DataMonitor.shared.begin(with: [])
  }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .database(Self.database)
        .environment(\.databaseChangePublicist, Self.databaseChangePublicist)
    }
}
