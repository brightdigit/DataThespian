//
//  ItemChild.swift
//  DataThespian
//
//  Created by Leo Dion on 10/16/24.
//
import Foundation
import SwiftData

@Model
internal final class ItemChild {
  internal var parent: Item?
  internal private(set) var timestamp: Date

  internal init(parent: Item? = nil, timestamp: Date) {
    self.parent = parent
    self.timestamp = timestamp
  }
}
