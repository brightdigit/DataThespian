//
// PublishingAgent.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(Combine) && canImport(SwiftData)

    @preconcurrency import Combine

    import Foundation

    actor PublishingAgent: DataAgent, Loggable {
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

        init(id: String, subject: PassthroughSubject<any DatabaseChangeSet, Never>) {
            self.id = id
            self.subject = subject
            Task {
                await self.initialize()
            }
        }

        func initialize() {
            cancellable = subject.handleEvents { _ in
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
            let oldCount = subscriptionCount
            let delta: Int = switch event {
            case .cancel:
                -1
            case .subscribe:
                1
            }

            subscriptionCount += delta
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
            cancellable?.cancel()
            cancellable = nil
            completed?()
            completed = nil
        }

        nonisolated func onCompleted(_ closure: @escaping @Sendable () -> Void) {
            Task {
                await self.setCompleted(closure)
            }
        }

        func setCompleted(_ closure: @escaping @Sendable () -> Void) {
          Self.logger.debug("SetCompleted \(self.id) \(self.agentID)")
            assert(completed == nil)
            completed = closure
        }

        func finish() {
            cancel()
        }
    }
#endif
