//
//  Thread.swift
//  DataThespian
//
//  Created by Leo Dion on 6/2/25.
//

import Foundation

extension Thread {
  internal var isRunningXCTest: Bool {
    threadDictionary.allKeys
      .contains {
        ($0 as? String)?
          .range(of: "XCTest", options: .caseInsensitive) != nil
      }
  }
}
