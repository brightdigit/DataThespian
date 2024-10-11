//
//  Item.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import Foundation
import SwiftData

@Model
internal final class Item {
  internal private(set) var timestamp: Date

  internal init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
