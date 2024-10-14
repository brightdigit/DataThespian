//
//  PublishingAgent.swift
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
  @preconcurrency import Combine
  import Foundation

  internal actor PublishingAgent: DataAgent, Loggable {
    private enum SubscriptionEvent: Sendable {
      case cancel
      case subscribe
    }

    internal static var loggingCategory: ThespianLogging.Category { .application }

    internal let agentID = UUID()
    private let id: String
    private let subject: PassthroughSubject<any DatabaseChangeSet, Never>
    private var subscriptionCount = 0
    private var cancellable: AnyCancellable?
    private var completed: (@Sendable () -> Void)?

    internal init(id: String, subject: PassthroughSubject<any DatabaseChangeSet, Never>) {
      self.id = id
      self.subject = subject
      Task { await self.initialize() }
    }

    private func initialize() {
      cancellable = subject.handleEvents { _ in
        self.onSubscriptionEvent(.subscribe)
      } receiveCancel: {
        self.onSubscriptionEvent(.cancel)
      }
      .sink {
        _ in
      }
    }

    private nonisolated func onSubscriptionEvent(_ event: SubscriptionEvent) {
      Task { await self.updateScriptionStatus(byEvent: event) }
    }

    private func updateScriptionStatus(byEvent event: SubscriptionEvent) {
      let oldCount = subscriptionCount
      let delta: Int =
        switch event {
        case .cancel: -1
        case .subscribe: 1
        }

      subscriptionCount += delta
      Self.logger.debug(
        // swiftlint:disable:next line_length
        "Updated Subscriptions for \(self.id) from \(oldCount) by \(delta) to \(self.subscriptionCount) \(self.agentID)"
      )
    }

    nonisolated internal func onUpdate(_ update: any DatabaseChangeSet) {
      Task { await self.sendUpdate(update) }
    }

    private func sendUpdate(_ update: any DatabaseChangeSet) {
      Task { @MainActor in await self.subject.send(update) }
    }

    private func cancel() {
      Self.logger.debug("Cancelling \(self.id) \(self.agentID)")
      cancellable?.cancel()
      cancellable = nil
      completed?()
      completed = nil
    }

    nonisolated internal func onCompleted(_ closure: @escaping @Sendable () -> Void) {
      Task { await self.setCompleted(closure) }
    }

    internal func setCompleted(_ closure: @escaping @Sendable () -> Void) {
      Self.logger.debug("SetCompleted \(self.id) \(self.agentID)")
      assert(completed == nil)
      completed = closure
    }

    internal func finish() { cancel() }
  }
#endif
