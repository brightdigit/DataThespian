//
//  ItemModel.swift
//  DataThespian
//
//  Created by Leo Dion on 10/10/24.
//

import DataThespian
import Foundation
import SwiftData

internal struct ItemModel: Identifiable {
  internal let model: Model<Item>
  internal let timestamp: Date

  internal var id: PersistentIdentifier {
    model.persistentIdentifier
  }

  private init(model: Model<Item>, timestamp: Date) {
    self.model = model
    self.timestamp = timestamp
  }

  internal init(item: Item) {
    self.init(model: .init(item), timestamp: item.timestamp)
  }
}
