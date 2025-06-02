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
      let agentID: UUID

      init(agentID: UUID = UUID()) {
        self.agentID = agentID
      }
      nonisolated func onUpdate(_ update: any DataThespian.DatabaseChangeSet) {
        Task {
          await self.notify(update)
        }
      }

      func finish() async {
      }

      private(set) var receivedUpdates: [any DatabaseChangeSet] = []

      func notify(_ update: any DatabaseChangeSet) {
        receivedUpdates.append(update)
      }
    }

    private final class MockAgentRegister: AgentRegister {
      func agent() async -> DataMonitorTests.MockAgent {
        agent
      }

      typealias AgentType = MockAgent

      let id: String
      let agent: MockAgent

      init(id: String, agent: MockAgent) {
        self.id = id
        self.agent = agent
      }
    }

    @Test internal func testSharedInstance() async {
      let monitor1 = DataMonitor.shared
      let monitor2 = DataMonitor.shared

      #expect(ObjectIdentifier(monitor1) == ObjectIdentifier(monitor2))
    }

    @Test internal func testBeginMonitoring() async {
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
