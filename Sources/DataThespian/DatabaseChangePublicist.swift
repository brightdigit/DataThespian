//
// DatabaseChangePublicist.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(Combine) && canImport(SwiftData)
  public import Combine

  private struct NeverDatabaseMonitor: DatabaseMonitoring {
    func register(_: any AgentRegister, force _: Bool) {
      assertionFailure("Using Empty Database Listener")
    }
  }

  public struct DatabaseChangePublicist: Sendable {
    let dbWatcher: DatabaseMonitoring
    public init(dbWatcher: any DatabaseMonitoring) {
      self.dbWatcher = dbWatcher
    }

    public static func never() -> DatabaseChangePublicist {
      self.init(dbWatcher: NeverDatabaseMonitor())
    }

    @Sendable
    public func callAsFunction(id: String) -> some Publisher<any DatabaseChangeSet, Never> {
      // print("Creating Publisher for \(id)")
      let subject = PassthroughSubject<any DatabaseChangeSet, Never>()
      dbWatcher.register(PublishingRegister(id: id, subject: subject), force: true)
      return subject
    }
  }
#endif
