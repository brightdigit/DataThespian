//
//  DatabaseChangePublicist.swift
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

#if canImport(Combine) && canImport(SwiftData)
  public import Combine

  private struct NeverDatabaseMonitor: DatabaseMonitoring {
    /// Registers an agent with the database monitor, but always fails.
    /// - Parameter agent: The agent to register.
    /// - Parameter force: A flag indicating whether the registration should be forced.
    func register(_: any AgentRegister, force _: Bool) {
      assertionFailure("Using Empty Database Listener")
    }
  }

  /// A struct that publishes database change events.
  public struct DatabaseChangePublicist: Sendable {
    private let dbWatcher: DatabaseMonitoring

    /// Initializes a new `DatabaseChangePublicist` instance.
    /// - Parameter dbWatcher: The database monitoring instance to use. Defaults to `DataMonitor.shared`.
    public init(dbWatcher: any DatabaseMonitoring = DataMonitor.shared) {
      self.dbWatcher = dbWatcher
    }

    /// Creates a `DatabaseChangePublicist` that never publishes any changes.
    public static func never() -> DatabaseChangePublicist {
      self.init(dbWatcher: NeverDatabaseMonitor())
    }

    /// Publishes database change events for the specified ID.
    /// - Parameter id: The ID of the entity to watch for changes.
    /// - Returns: A publisher that emits `DatabaseChangeSet` values
    /// whenever the database changes for the specified ID.
    @Sendable public func callAsFunction(id: String) -> some Publisher<any DatabaseChangeSet, Never>
    {
      // print("Creating Publisher for \(id)")
      let subject = PassthroughSubject<any DatabaseChangeSet, Never>()
      dbWatcher.register(PublishingRegister(id: id, subject: subject), force: true)
      return subject
    }
  }
#endif
