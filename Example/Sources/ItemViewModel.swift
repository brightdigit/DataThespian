//
//  ItemModel.swift
//  DataThespian
//
//  Created by Leo Dion on 10/10/24.
//

import DataThespian
import Foundation
import SwiftData

internal struct ItemViewModel: Sendable, Identifiable {
  internal let model: Model<Item>
  internal let timestamp: Date
  internal let children: [ChildViewModel]

  internal var id: PersistentIdentifier {
    model.persistentIdentifier
  }

  private init(model: Model<Item>, timestamp: Date, children: [ChildViewModel]?) {
    self.model = model
    self.timestamp = timestamp
    self.children = children ?? []
  }

  internal init(item: Item) {
    self.init(
      model: .init(item),
      timestamp: item.timestamp,
      children: item.children?.map(ChildViewModel.init)
    )
  }
}
