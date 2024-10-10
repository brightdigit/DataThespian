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
  init () {
    DataMonitor.shared.begin(with: [])
  }
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
