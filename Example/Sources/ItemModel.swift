//
//  ItemModel.swift
//  DataThespian
//
//  Created by Leo Dion on 10/10/24.
//

import Foundation
import DataThespian
import SwiftData



struct ItemModel : Identifiable {
  private init(model: ModelID<Item>, timestamp: Date) {
    self.model = model
    self.timestamp = timestamp
  }
  
  internal init(item : Item) {
    self.init(model: .init(item), timestamp: item.timestamp)
  }
  @available(*, deprecated)
  internal init(id: PersistentIdentifier, timestamp: Date) {
    self.model = .init(persistentIdentifier: id)
    self.timestamp = timestamp
  }
  
  var id : PersistentIdentifier {
    return model.persistentIdentifier
  }
  let model : ModelID<Item>
  let timestamp: Date
}
