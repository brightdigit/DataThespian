//
//  ContentView.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import SwiftUI
import SwiftData
import DataThespian

struct ContentView: View {
    
    private var items = [Item]()
  private let database = try! BackgroundDatabase(modelContainer: .init(for: Item.self))

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
          
        }
    }

    private func addItem() {
      
          Task {
            await self.database.withModelContext { modelContext in
              let newItem = Item(timestamp: Date())
              modelContext.insert(newItem)
            }
          }
      
    }

    private func deleteItems(offsets: IndexSet) {
      
        Task {
          
              for index in offsets {
                let model = ModelID(items[index])
          await self.database.withModelContext { modelContext in
            
            if let model : Item  = modelContext.registeredModel(for: model.persistentIdentifier) {
              modelContext.delete(model)
            }
                }
          }
          
        
      }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
