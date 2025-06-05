import Foundation
import Testing

@testable import DataThespian

#if canImport(Combine) && canImport(SwiftData) && canImport(CoreData)
  import Combine
  import CoreData
  import SwiftData

  @Suite(.enabled(if: swiftDataIsAvailable()), .serialized)
  internal struct DataMonitorTests {
    private actor MockAgent: DataAgent {
      fileprivate private(set) var receivedUpdates: [any DatabaseChangeSet] = []
      let agentID: UUID

      init(agentID: UUID = UUID()) {
        self.agentID = agentID
      }

      nonisolated func onUpdate(_ update: any DataThespian.DatabaseChangeSet) {
        Task {
          await self.notify(update)
        }
      }

      fileprivate func finish() async {
      }

      fileprivate func notify(_ update: any DatabaseChangeSet) {
        receivedUpdates.append(update)
      }
    }

    private final class MockAgentRegister: AgentRegister {
      typealias AgentType = MockAgent

      fileprivate let id: String
      private let agent: MockAgent

      fileprivate init(id: String, agent: MockAgent) {
        self.id = id
        self.agent = agent
      }

      fileprivate func agent() async -> DataMonitorTests.MockAgent {
        agent
      }
    }

    @Test internal func testSharedInstance() async {
      let monitor1 = DataMonitor.shared
      let monitor2 = DataMonitor.shared

      #expect(ObjectIdentifier(monitor1) == ObjectIdentifier(monitor2))
    }

    @Test(.disabled(if: !Thread.current.isRunningXCTest, "Unavailable in Swift Package Manager."))
    internal func testBeginMonitoring() async {
      let monitor = DataMonitor.shared
      let agent = MockAgent()
      let registration = MockAgentRegister(id: "testBeginMonitoring", agent: agent)
      await monitor.allowEmptyChangesForTesting()

      // Begin monitoring with the agent
      monitor.begin(with: [registration])

      // Wait a bit for async setup
      try? await Task.sleep(nanoseconds: 100_000_000)
      let queuedUpdates = await agent.receivedUpdates.count

      // Create and send a test notification
      let notification = Notification(
        name: .NSManagedObjectContextDidSaveObjectIDs,
        object: nil,
        userInfo: [:]
      )

      // Post the notification
      NotificationCenter.default.post(notification)

      // Wait a bit for async notification
      try? await Task.sleep(nanoseconds: 100_000_000)

      // Verify the agent received the update
      await #expect(agent.receivedUpdates.count - queuedUpdates > 1)
    }
  }
#endif
