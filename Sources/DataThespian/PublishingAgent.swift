//
// PublishingAgent.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(Combine) && canImport(SwiftData)


  @preconcurrency import Combine

  import Foundation

  internal actor PublishingAgent: DataAgent, Loggable {
    private enum SubscriptionEvent: Sendable {
      case cancel
      case subscribe
    }

    static var loggingCategory: ThespianLogging.Category {
      .application
    }

    let agentID = UUID()
    let id: String
    let subject: PassthroughSubject<any DatabaseChangeSet, Never>
    var subscriptionCount = 0
    var cancellable: AnyCancellable?
    var completed: (@Sendable () -> Void)?

    internal init(id: String, subject: PassthroughSubject<any DatabaseChangeSet, Never>) {
      self.id = id
      self.subject = subject
      Task {
        await self.initialize()
      }
    }

    func initialize() {
      self.cancellable = subject.handleEvents { _ in
        self.onSubscriptionEvent(.subscribe)
      } receiveCancel: {
        self.onSubscriptionEvent(.cancel)
      }
      .sink { _ in }
    }

    private nonisolated func onSubscriptionEvent(_ event: SubscriptionEvent) {
      Task {
        await self.updateScriptionStatus(byEvent: event)
      }
    }

    private func updateScriptionStatus(byEvent event: SubscriptionEvent) {
      let oldCount = self.subscriptionCount
      let delta: Int = switch event {
      case .cancel:
        -1
      case .subscribe:
        1
      }

      self.subscriptionCount += delta
      Self.logger.debug(
        // swiftlint:disable:next line_length
        "Updated Subscriptions for \(self.id) from \(oldCount) by \(delta) to \(self.subscriptionCount) \(self.agentID)"
      )
    }

    nonisolated func onUpdate(_ update: any DatabaseChangeSet) {
      Task {
        await self.sendUpdate(update)
      }
    }

    func sendUpdate(_ update: any DatabaseChangeSet) {
      Task { @MainActor in
        await self.subject.send(update)
      }
    }

    func cancel() {
      Self.logger.debug("Cancelling \(self.id) \(self.agentID)")
      self.cancellable?.cancel()
      self.cancellable = nil
      self.completed?()
      self.completed = nil
    }

    nonisolated func onCompleted(_ closure: @escaping @Sendable () -> Void) {
      Task {
        await self.setCompleted(closure)
      }
    }

    func setCompleted(_ closure: @escaping @Sendable () -> Void) {
      Self.logger.debug("SetCompleted \(self.id) \(self.agentID)")
      assert(self.completed == nil)
      self.completed = closure
    }

    func finish() {
      self.cancel()
    }
  }
#endif
