//
//  ItemChildView.swift
//  DataThespianExample
//
//  Created by Leo Dion on 10/16/24.
//

import SwiftUI

internal struct ItemChildView: View {
  internal var object: ContentObject
  internal let item: ItemViewModel
  internal var body: some View {
    VStack {
      Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
      Divider()
      Button("Add Child") {
        object.addChild(to: item)
      }
      ForEach(item.children) { child in
        Text(
          "Child at \(child.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))"
        )
      }
    }
  }
}
//
// #Preview {
//    ItemChildView()
// }
