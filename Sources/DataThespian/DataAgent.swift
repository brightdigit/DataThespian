//
// DataAgent.swift
// Copyright (c) 2024 BrightDigit.
//

public import Foundation

#if canImport(SwiftData)

  public protocol DataAgent: Sendable {
    var agentID: UUID { get }
    func onUpdate(_ update: any DatabaseChangeSet)
    func onCompleted(_ closure: @Sendable @escaping () -> Void)
    func finish() async
  }

  extension DataAgent {
    public func onCompleted(_: @Sendable @escaping () -> Void) {}
  }
#endif
