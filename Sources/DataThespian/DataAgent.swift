//
// DataAgent.swift
// Copyright (c) 2024 BrightDigit.
//



#if canImport(SwiftData)
public import Foundation
    public protocol DataAgent: Sendable {
        var agentID: UUID { get }
        func onUpdate(_ update: any DatabaseChangeSet)
        func onCompleted(_ closure: @Sendable @escaping () -> Void)
        func finish() async
    }

    public extension DataAgent {
        func onCompleted(_: @Sendable @escaping () -> Void) {}
    }
#endif
