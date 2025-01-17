//
//  PublishingRegister.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

  /// A register that manages the publication of database changes.
  internal struct PublishingRegister: AgentRegister {
    /// The unique identifier for the register.
    internal let id: String

    /// The subject that publishes database change sets.
    private let subject: PassthroughSubject<any DatabaseChangeSet, Never>

    /// Initializes a new instance of `PublishingRegister`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the register.
    ///   - subject: The subject that publishes database change sets.
    internal init(id: String, subject: PassthroughSubject<any DatabaseChangeSet, Never>) {
      self.id = id
      self.subject = subject
    }

    /// Creates a new publishing agent.
    ///
    /// - Returns: A new instance of `PublishingAgent`.
    internal func agent() async -> PublishingAgent {
      let agent = AgentType(id: id, subject: subject)

      return agent
    }
  }
#endif
