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



struct ContentView: View {
  @State var object = ContentObject()
  @Environment(\.database) var database
  @Environment(\.databaseChangePublicist) var databaseChangePublisher
  
  
  
  var body: some View {
    NavigationSplitView {
      List(selection: self.$object.selectedItemsID) {
        ForEach(object.items) { item in
          Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
        .onDelete(perform: object.deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
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
      self.object.initialize(withDatabase: database, databaseChangePublisher: databaseChangePublisher)
    }
  }
  
  private func addItem() {
    self.addItem(withDate: .init())
  }
  private func addItem(withDate date: Date ) {
    self.object.addItem(withDate: .init())
  }
  
}

#Preview {
  ContentView()
}
