//
//  ContentObject.swift
//  DataThespian
//
//  Created by Leo Dion on 10/10/24.
//

import Combine
import DataThespian
import Foundation
import SwiftData

@Observable
@MainActor
internal class ContentObject {
  internal let databaseChangePublisher = PassthroughSubject<any DatabaseChangeSet, Never>()
  private var databaseChangeCancellable: AnyCancellable?
  private var databaseChangeSubscription: AnyCancellable?
  private var database: (any Database)?
  internal private(set) var items = [ItemViewModel]()
  internal var selectedItemsID: Set<ItemViewModel.ID> = []
  private var newItem: AnyCancellable?
  internal var error: (any Error)?

  internal var selectedItems: [ItemViewModel] {
    let selectedItemsID = self.selectedItemsID
    let items: [ItemViewModel]
    do {
      items = try self.items.filter(
        #Predicate<ItemViewModel> {
          selectedItemsID.contains($0.id)
        }
      )
    } catch {
      assertionFailure("Unable to filter selected items: \(error.localizedDescription)")
      self.error = error
      items = []
    }
    // assert(items.count == selectedItemsID.count)
    return items
  }

  internal init() {
    self.databaseChangeSubscription = self.databaseChangePublisher.sink { _ in
      self.beginUpdateItems()
    }
  }

  private static func deleteModels(_ models: [Model<Item>], from database: (any Database))
    async throws
  {
    try await database.deleteModels(models)
  }

  private func beginUpdateItems() {
    Task {
      do {
        try await self.updateItems()
      } catch {
        self.error = error
      }
    }
  }

  private func updateItems() async throws {
    guard let database else {
      return
    }
    self.items = try await database.withModelContext { modelContext in
      let items = try modelContext.fetch(FetchDescriptor<Item>())
      return items.map(ItemViewModel.init)
    }
  }

  internal func initialize(
    withDatabase database: any Database, databaseChangePublisher: DatabaseChangePublicist
  ) {
    self.database = database
    self.databaseChangeCancellable = databaseChangePublisher(id: "contentView")
      .subscribe(self.databaseChangePublisher)
    self.beginUpdateItems()
  }

  internal func deleteSelectedItems() {
    let models = self.selectedItems.map {
      Model<Item>(persistentIdentifier: $0.id)
    }
    self.deleteItems(models)
  }
  internal func deleteItems(offsets: IndexSet) {
    let models =
      offsets
      .compactMap { items[$0].id }
      .map(Model<Item>.init(persistentIdentifier:))

    assert(models.count == offsets.count)

    self.deleteItems(models)
  }

  internal func deleteItems(_ models: [Model<Item>]) {
    guard let database else {
      return
    }
    Task {
      try await Self.deleteModels(models, from: database)
      try await database.save()
    }
  }

  internal func addChild(to item: ItemViewModel) {
    guard let database else {
      return
    }
    Task {
      let timestamp = Date()
      let childModel = await database.insert {
        ItemChild(timestamp: timestamp)
      }

      try await database.withModelContext { modelContext in
        let item = try modelContext.get(item.model)
        let child = try modelContext.get(childModel)
        assert(child != nil && item != nil)
        child?.parent = item
        try modelContext.save()
      }
    }
  }

  internal func addItem(withDate date: Date = .init()) {
    guard let database else {
      return
    }
    Task {
      let insertedModel = await database.insert { Item(timestamp: date) }
      print("inserted:", insertedModel.isTemporary)
      try await database.save()
      let savedModel = try await database.get(
        for: .predicate(
          #Predicate<Item> {
            $0.timestamp == date
          }
        )
      )
      print("saved:", savedModel.isTemporary)
    }
  }
}
