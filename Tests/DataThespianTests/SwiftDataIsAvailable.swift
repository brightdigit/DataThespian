//
//  SwiftDataIsAvailable.swift
//  DataThespian
//
//  Created by Leo Dion on 1/7/25.
//

internal func swiftDataIsAvailable() -> Bool {
  #if canImport(SwiftData)
    true
  #else
    false
  #endif
}
