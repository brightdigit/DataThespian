//
//  CoreDataNotificationKeysTests.swift
//  DataThespian
//
//  Created by Testing Team.
//

import Foundation
import Testing

@testable import DataThespian

#if canImport(Combine) && canImport(SwiftData) && canImport(CoreData)
  import Combine
  import CoreData
  import SwiftData

  @Suite(.enabled(if: swiftDataIsAvailable()), .serialized)
  internal struct CoreDataNotificationKeysTests {
    @Test
    internal func testNotificationConstruction() {
      // Arrange
      let userInfo: [AnyHashable: Any] = [
        NSInsertedObjectIDsKey: Set<NSManagedObjectID>()
      ]

      // Act
      let notification = Notification(
        name: .NSManagedObjectContextDidSaveObjectIDs,
        object: nil,
        userInfo: userInfo
      )

      // Assert
      #expect(notification.name == .NSManagedObjectContextDidSaveObjectIDs)
    }
  }
#endif
