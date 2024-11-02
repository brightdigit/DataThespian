//
//  DataAgent.swift
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
  public import Foundation
  /// A protocol that defines a data agent responsible for managing database updates and completions.
  public protocol DataAgent: Sendable {
    /// The unique identifier of the agent.
    var agentID: UUID { get }

    /// Called when the database is updated.
    ///
    /// - Parameter update: The database change set.
    func onUpdate(_ update: any DatabaseChangeSet)

    /// Called when the data agent's operations are completed.
    ///
    /// - Parameter closure: The closure to be executed when the operations are completed.
    func onCompleted(_ closure: @Sendable @escaping () -> Void)

    /// Finishes the data agent's operations.
    ///
    /// - Returns: An asynchronous task that completes when the data agent's operations are finished.
    func finish() async
  }

  extension DataAgent {
    /// Called when the data agent's operations are completed.
    ///
    /// - Parameter closure: The closure to be executed when the operations are completed.
    public func onCompleted(_: @Sendable @escaping () -> Void) {}
  }
#endif
