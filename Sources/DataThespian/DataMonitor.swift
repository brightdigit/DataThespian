//
// DataMonitor.swift
// Copyright (c) 2024 BrightDigit.
//
@inlinable
public func assert(isMainThread: Bool) {
  assert(isMainThread == Thread.isMainThread)
}
#if canImport(Combine) && canImport(SwiftData) && canImport(CoreData)



  import Combine

  import CoreData

  import Foundation
  import SwiftData

public actor DataMonitor: DatabaseMonitoring, Loggable {
    public static var loggingCategory: ThespianLogging.Category {
      .data
    }

    public static let shared = DataMonitor()

    var object: (any NSObjectProtocol)?
    var registrations = RegistrationCollection()

    private init() {
      Self.logger.debug("Creating DatabaseMonitor")
    }

    public nonisolated func register(_ registration: any AgentRegister, force: Bool) {
      Task {
        await self.addRegistration(registration, force: force)
      }
    }

    func addRegistration(_ registration: any AgentRegister, force: Bool) {
      self.registrations.add(withID: registration.id, force: force, agent: registration.agent)
    }

    public nonisolated func begin(with builders: [any AgentRegister]) {
      Task {
        await self.addObserver()
        for builder in builders {
          await self.addRegistration(builder, force: false)
        }
      }
    }

    func addObserver() {
      guard object == nil else {
        return
      }
      self.object = NotificationCenter.default.addObserver(
        forName: .NSManagedObjectContextDidSave,
        object: nil,
        queue: nil,
        using: { notification in
          let update = NotificationDataUpdate(notification)
          Task {
            await self.notifyRegisration(update)
          }
        }
      )
    }

    func notifyRegisration(_ update: any DatabaseChangeSet) {
      guard !update.isEmpty else {
        return
      }
      Self.logger.debug("Notifying of Update")

      self.registrations.notify(update)
    }
  }
#endif
