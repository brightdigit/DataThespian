//
// PublishingRegister.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(Combine) && canImport(SwiftData)
  @preconcurrency import Combine

  import Foundation

  internal struct PublishingRegister: AgentRegister {
    let id: String
    let subject: PassthroughSubject<any DatabaseChangeSet, Never>

    func agent() async -> PublishingAgent {
      let agent = AgentType(id: id, subject: subject)

      return agent
    }
  }
#endif
