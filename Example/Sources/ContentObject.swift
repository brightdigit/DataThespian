//
//  ContentObject.swift
//  DataThespian
//
//  Created by Leo Dion on 10/10/24.
//

import Foundation
import SwiftData
import DataThespian
import Combine



@Observable
@MainActor
class ContentObject {
  internal let databaseChangePublisher = PassthroughSubject<any DatabaseChangeSet, Never>()
  private var databaseChangeCancellable : AnyCancellable?
  private var databaseChangeSubscription: AnyCancellable?
  private var database : (any Database)?
  internal private(set) var items = [ItemModel]()
  internal var selectedItemsID: Set<ItemModel.ID> = []
  
  
  var selectedItems : [ItemModel] {
    let selectedItemsID = self.selectedItemsID
    return try! self.items.filter(#Predicate<ItemModel> {
      selectedItemsID.contains($0.id)
    })
  }
  private var newItem: AnyCancellable?
  var error: (any Error)?
  
  private func beginUpdateItems() {
    Task {
      do {
        try await self.updateItems()
      } catch {
        self.error = error
      }
    }
  }
  fileprivate func updateItems() async throws {
    guard let database else {
      return
    }
    self.items = try await database.withModelContext({ modelContext in
      let items = try modelContext.fetch(FetchDescriptor<Item>())
      return items.map(ItemModel.init)
    })
  }
  
  internal init () {
    self.databaseChangeSubscription =    self.databaseChangePublisher.sink { _ in
      self.beginUpdateItems()
    }
  }
  
  internal func initialize(withDatabase database: any Database, databaseChangePublisher: DatabaseChangePublicist) {
    self.database = database
    self.databaseChangeCancellable =    databaseChangePublisher(id: "contentView")
      .subscribe(self.databaseChangePublisher)
    self.beginUpdateItems()
  }
  
  
  
  fileprivate static func deleteModels( _ models: [ModelID<Item>], from database: (any Database)) async throws {
    try await database.withModelContext { modelContext in
      let items : [Item] = models.compactMap{
        modelContext.model(for: $0.persistentIdentifier) as? Item
      }
      dump(items.first?.persistentModelID)
      assert(items.count == models.count)
      for item in items {
        modelContext.delete(item)
      }
      try modelContext.save()
    }
  }
  internal func deleteSelectedItems() {
    let models = self.selectedItems.map {
      ModelID<Item>.init(persistentIdentifier: $0.id)
    }
    self.deleteItems(models)
  }
  internal func deleteItems(offsets: IndexSet) {
    
    let models = offsets
      .compactMap{items[$0].id}
      .map(ModelID<Item>.init(persistentIdentifier: ))
    
    assert(models.count == offsets.count)
    
    self.deleteItems(models)
  }
  
  internal func deleteItems(_ models: [ModelID<Item>]) {
    guard let database else {
      return
    }
    Task {
      try await Self.deleteModels(models, from: database)
    }
  }
  
  internal func addItem(withDate date: Date = .init()) {
    guard let database else {
      return
    }
    Task {
      try await database.withModelContext { modelContext in
        
        let newItem = Item(timestamp: date)
        modelContext.insert(newItem)
        dump(newItem.persistentModelID)
        try modelContext.save()
      }
    }
  }
}
