//
//  Item.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import DataThespian
import Foundation
import SwiftData

@Model
internal final class Item: Unique {
  internal private(set) var timestamp: Date

  internal init(timestamp: Date) {
    self.timestamp = timestamp
  }

  enum Keys: UniqueKeys {
    typealias Model = Item

    static let timestamp = keyPath(\.timestamp)
  }
}
