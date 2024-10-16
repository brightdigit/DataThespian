//
//  ChildViewModel.swift
//  DataThespian
//
//  Created by Leo Dion on 10/16/24.
//

import DataThespian
import Foundation
import SwiftData

internal struct ChildViewModel: Sendable, Identifiable {
  internal let model: Model<ItemChild>
  internal let timestamp: Date

  internal var id: PersistentIdentifier {
    model.persistentIdentifier
  }

  private init(model: Model<ItemChild>, timestamp: Date) {
    self.model = model
    self.timestamp = timestamp
  }

  internal init(child: ItemChild) {
    self.init(model: .init(child), timestamp: child.timestamp)
  }
}
