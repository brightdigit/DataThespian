import Foundation
import Testing

@testable import DataThespian

#if canImport(Combine) && canImport(SwiftData)
  @preconcurrency import Combine
  import SwiftData
#endif

@Suite(.enabled(if: swiftDataIsAvailable()))
internal struct PublishingAgentTests {
  @Test internal func testSendUpdate() async throws {
    #if canImport(Combine) && canImport(SwiftData)
      // Create a PassthroughSubject to receive updates
      let subject = PassthroughSubject<any DatabaseChangeSet, Never>()
      
      // Create a simple DatabaseChangeSet mock
      struct MockChangeSet: DatabaseChangeSet {
        let id: UUID = UUID()
      }
      
      // Create the PublishingAgent
      let agent = PublishingAgent(id: "testAgent", subject: subject)
      
      // Create a subscriber to track published updates
      var receivedUpdates: [any DatabaseChangeSet] = []
      var cancellable: AnyCancellable?
      
      // Set up a MainActor task to subscribe to the subject
      let expectation = Expectation(description: "Update received")
      
      await MainActor.run {
        cancellable = subject.sink { update in
          receivedUpdates.append(update)
          expectation.fulfill()
        }
      }
      
      // Create a mock change set and send the update
      let mockUpdate = MockChangeSet()
      agent.onUpdate(mockUpdate)
      
      // Wait for the update to be processed
      await expectation.fulfill(timeout: 2.0)
      
      #expect(receivedUpdates.count == 1, "Should receive exactly one update")
    #endif
  }
}