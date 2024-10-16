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
  internal enum Keys: UniqueKeys {
    internal typealias Model = Item
    internal static let primary = timestamp
    internal static let timestamp = keyPath(\.timestamp)
  }

  internal private(set) var timestamp: Date

  internal init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
