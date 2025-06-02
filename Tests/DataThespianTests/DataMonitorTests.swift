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
      
      internal private(set) var receivedUpdates: [any DatabaseChangeSet] = []
      
      func notify(_ update: any DatabaseChangeSet) {
        receivedUpdates.append(update)
      }
    }
    
    private final class MockAgentRegister: AgentRegister {
      func agent() async -> DataMonitorTests.MockAgent {
        return agent
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
    
    @Test internal func testRegisterAgent() async {
      let monitor = DataMonitor.shared
      let agent = MockAgent()
      let registration = MockAgentRegister(id: "testRegisterAgent", agent: agent)
      monitor.begin(with: [registration])
      await monitor.allowEmptyChangesForTesting()
      
      
      await print("Current count",agent.receivedUpdates.count)
      // Wait a bit for async registration
      try? await Task.sleep(nanoseconds: 500_000_000)
      
      // Create and send a test notification
      let notification = Notification(
        name: .NSManagedObjectContextDidSaveObjectIDs,
        object: nil,
        userInfo: [ NSInsertedObjectIDsKey : [ NSManagedObjectID() ]]
      )
      
      // Post the notification
      NotificationCenter.default.post(notification)
      
      // Wait a bit for async notification
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Verify the agent received the update
      await #expect(agent.receivedUpdates.count == 1)
    }
    
    @Test internal func testRegisterAgentWithForce() async {
      let monitor = DataMonitor.shared
      let agent1 = MockAgent()
      let agent2 = MockAgent()
      
      let registration1 = MockAgentRegister(id: "test1", agent: agent1)
      let registration2 = MockAgentRegister(id: "test2", agent: agent2)
      
      // Register first agent
      monitor.register(registration1, force: false)
      
      // Try to register second agent without force
      monitor.register(registration2, force: false)
      
      // Wait a bit for async registration
      try? await Task.sleep(nanoseconds: 100_000_000)
      
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
      
      // Verify only the first agent received the update
      await #expect(agent1.receivedUpdates.count == 1)
      await #expect(agent2.receivedUpdates.count == 0)
      
      // Now register with force
      monitor.register(registration2, force: true)
      
      // Wait a bit for async registration
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Post another notification
      NotificationCenter.default.post(notification)
      
      // Wait a bit for async notification
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Verify the second agent now receives updates
      await #expect(agent2.receivedUpdates.count == 1)
    }
    
    @Test internal func testBeginMonitoring() async {
      let monitor = DataMonitor.shared
      let agent = MockAgent()
      let registration = MockAgentRegister(id: "test", agent: agent)
      
      // Begin monitoring with the agent
      monitor.begin(with: [registration])
      
      // Wait a bit for async setup
      try? await Task.sleep(nanoseconds: 100_000_000)
      
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
      await #expect(agent.receivedUpdates.count == 1)
    }
    
    @Test internal func testEmptyUpdateNotification() async {
      let monitor = DataMonitor.shared
      let agent = MockAgent()
      let registration = MockAgentRegister(id: "test", agent: agent)
      
      // Register the agent
      monitor.register(registration, force: false)
      
      // Wait a bit for async registration
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Create and send a test notification with empty update
      let notification = Notification(
        name: .NSManagedObjectContextDidSaveObjectIDs,
        object: nil,
        userInfo: [:]
      )
      
      // Post the notification
      NotificationCenter.default.post(notification)
      
      // Wait a bit for async notification
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Verify the agent received the update (even if empty)
      await #expect(agent.receivedUpdates.count == 1)
    }
  }
#endif 
