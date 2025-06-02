//
//  Parent.swift
//  DataThespian
//
//  Created by Leo Dion on 1/7/25.
//

#if canImport(SwiftData)
  import Foundation
  import SwiftData

  @Model
  internal class Parent {
    internal var id: UUID
    @Relationship(inverse: \Child.parent)
    internal var children: [Child]? = []
    internal init(id: UUID) {
      self.id = id
    }
  }
#endif
