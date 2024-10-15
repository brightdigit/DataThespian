//
//  Item.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/10/24.
//

import Foundation
import SwiftData
import DataThespian

@Model
internal final class Item : Unique {
  internal private(set) var timestamp: Date

  internal init(timestamp: Date) {
    self.timestamp = timestamp
  }
  
  enum Keys : UniqueKeySet {
    typealias Model = Item
    
    static let timestamp : UniqueKey = Self.unique(\.timestamp)
    


  }
}
