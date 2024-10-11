//
//  ContentView.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import Combine
import DataThespian
import SwiftData
import SwiftUI

internal struct ContentView: View {
  @State private var object = ContentObject()
  @Environment(\.database) private var database
  @Environment(\.databaseChangePublicist) private var databaseChangePublisher

  internal var body: some View {
    NavigationSplitView {
      List(selection: self.$object.selectedItemsID) {
        ForEach(object.items) { item in
          Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
        .onDelete(perform: object.deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 220)
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
        ToolbarItem {
          Button(action: object.deleteSelectedItems) {
            Label("Delete Selected Items", systemImage: "trash")
          }
        }
      }
    } detail: {
      let selectedItems = object.selectedItems
      if selectedItems.count > 1 {
        Text("Multiple Selected")
      } else if let item = selectedItems.first {
        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
      } else {
        Text("Select an item")
      }
    }.onAppear {
      self.object.initialize(
        withDatabase: database,
        databaseChangePublisher: databaseChangePublisher
      )
    }
  }

  private func addItem() {
    self.addItem(withDate: .init())
  }
  private func addItem(withDate date: Date) {
    self.object.addItem(withDate: .init())
  }
}

#Preview {
  let databaseChangePublicist = DatabaseChangePublicist(dbWatcher: DataMonitor.shared)
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  // swiftlint:disable:next force_try
  let modelContainer = try! ModelContainer(for: Item.self, configurations: config)

  let backgroundDatabase = BackgroundDatabase(modelContainer: modelContainer) {
    let context = ModelContext($0)
    context.autosaveEnabled = true
    return context
  }

  ContentView()
    .environment(      \.databaseChangePublicist, databaseChangePublicist    )
    .database(backgroundDatabase)
}
