//
//  RegistrationCollection.swift
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

#if canImport(SwiftData)

  import Foundation

  internal actor RegistrationCollection: Loggable {
    internal static var loggingCategory: ThespianLogging.Category { .application }

    private var registrations = [String: DataAgent]()

    nonisolated internal func notify(_ update: any DatabaseChangeSet) {
      Task {
        await self.onUpdate(update)
        Self.logger.debug("Notification Complete")
      }
    }

    nonisolated internal func add(
      withID id: String, force: Bool, agent: @Sendable @escaping () async -> DataAgent
    ) { Task { await self.append(withID: id, force: force, agent: agent) } }

    private func append(
      withID id: String, force: Bool, agent: @Sendable @escaping () async -> DataAgent
    ) async {
      if let registration = registrations[id], force {
        Self.logger.debug("Overwriting \(id). Already exists.")
        await registration.finish()
      } else if registrations[id] != nil {
        Self.logger.debug("Can't register \(id). Already exists.")
        return
      }
      Self.logger.debug("Registering \(id)")
      let agent = await agent()
      agent.onCompleted { Task { await self.remove(withID: id, agentID: agent.agentID) } }
      registrations[id] = agent
      Self.logger.debug("Registration Count \(self.registrations.count)")
    }

    private func remove(withID id: String, agentID: UUID) {
      guard let agent = registrations[id] else {
        Self.logger.warning("No matching registration with id: \(id)")
        return
      }
      guard agent.agentID == agentID else {
        Self.logger.warning("No matching registration with agentID: \(agentID)")
        return
      }
      registrations.removeValue(forKey: id)
      Self.logger.debug("Registration Count \(self.registrations.count)")
    }

    private func onUpdate(_ update: any DatabaseChangeSet) {
      for (id, registration) in registrations {
        Self.logger.debug("Notifying \(id)")
        registration.onUpdate(update)
      }
    }
  }
#endif
