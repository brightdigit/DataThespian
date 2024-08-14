//
// DatabaseMonitoring.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
  public protocol DatabaseMonitoring: Sendable {
    func register(_ registration: any AgentRegister, force: Bool)
  }
#endif
