//
// AgentRegister.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
    public protocol AgentRegister: Sendable {
        associatedtype AgentType: DataAgent
        var id: String { get }
        @Sendable
        func agent() async -> AgentType
    }

    public extension AgentRegister {
        var id: String {
            "\(AgentType.self)"
        }
    }
#endif
