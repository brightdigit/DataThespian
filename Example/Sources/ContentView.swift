//
//  ContentView.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import SwiftUI
import SwiftData
import DataThespian
import Combine

struct ItemModel : Identifiable {
  internal init(item : Item) {
    self.init(id: item.persistentModelID, timestamp: item.timestamp)
  }
  internal init(id: PersistentIdentifier, timestamp: Date) {
    self.id = id
    self.timestamp = timestamp
  }
  
  let id : PersistentIdentifier
  let timestamp: Date
}
struct ContentView: View {
  private static let databaseChangePublicist = DatabaseChangePublicist(dbWatcher: DataMonitor.shared)
  @State private var items = [ItemModel]()
  @State private var newItem: AnyCancellable?
  private static let database = try! BackgroundDatabase(modelContainer: .init(for: Item.self), autosaveEnabled: true)

  fileprivate func updateItems() async throws {
    self.items = try await Self.database.withModelContext({ modelContext in
      let items = try modelContext.fetch(FetchDescriptor<Item>())
      return items.map(ItemModel.init)
    })
  }
  
  var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }.onAppear {
          self.newItem = Self.databaseChangePublicist(id: "contentView").sink { changes in
            Task {
              try await updateItems()
            }
          }
          Task {
            try await updateItems()
          }
        }
    }

    private func addItem() {
      
          Task {
            try await Self.database.withModelContext { modelContext in
              let timestamp = Date()
              let newItem = Item(timestamp: timestamp)
              modelContext.insert(newItem)
              try modelContext.save()
            }
          }
      
    }

    private func deleteItems(offsets: IndexSet) {
      
        Task {
          let models = offsets
            .compactMap{items[$0].id}
            .map(ModelID<Item>.init(persistentIdentifier: ))
          try await Self.database.withModelContext { modelContext in
            let items : [Item] = models.compactMap{
              modelContext.registeredModel(for: $0.persistentIdentifier)
            }
            assert(items.count == offsets.count)
            for item in items {
              modelContext.delete(item)
            }
            try modelContext.save()
          }
          
        
      }
    }
}

#Preview {
    ContentView()
        //.modelContainer(for: Item.self, inMemory: true)
}
