//
//  DataMonitor.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(Combine) && canImport(SwiftData) && canImport(CoreData)
  @inlinable public func assert(isMainThread: Bool) { assert(isMainThread == Thread.isMainThread) }

  import Combine

  import CoreData

  import Foundation
  import SwiftData

  public actor DataMonitor: DatabaseMonitoring, Loggable {
    public static var loggingCategory: ThespianLogging.Category { .data }

    public static let shared = DataMonitor()

    var object: (any NSObjectProtocol)?
    var registrations = RegistrationCollection()

    private init() { Self.logger.debug("Creating DatabaseMonitor") }

    public nonisolated func register(_ registration: any AgentRegister, force: Bool) {
      Task { await self.addRegistration(registration, force: force) }
    }

    func addRegistration(_ registration: any AgentRegister, force: Bool) {
      registrations.add(withID: registration.id, force: force, agent: registration.agent)
    }

    public nonisolated func begin(with builders: [any AgentRegister]) {
      Task {
        await self.addObserver()
        for builder in builders { await self.addRegistration(builder, force: false) }
      }
    }

    func addObserver() {
      guard object == nil else { return }
      object = NotificationCenter.default.addObserver(
        forName: .NSManagedObjectContextDidSave,
        object: nil,
        queue: nil,
        using: { notification in
          let update = NotificationDataUpdate(notification)
          Task { await self.notifyRegisration(update) }
        }
      )
    }

    func notifyRegisration(_ update: any DatabaseChangeSet) {
      guard !update.isEmpty else { return }
      Self.logger.debug("Notifying of Update")

      registrations.notify(update)
    }
  }
#endif
