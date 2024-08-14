//
// DatabaseChangeType.swift
// Copyright (c) 2024 BrightDigit.
//

public enum DatabaseChangeType: CaseIterable, Sendable {
  case inserted
  case deleted
  case updated
  #if canImport(SwiftData)
    var keyPath: KeyPath<any DatabaseChangeSet, Set<ManagedObjectMetadata>> {
      switch self {
      case .inserted:
        \.inserted
      case .deleted:
        \.deleted
      case .updated:
        \.updated
      }
    }
  #endif
}

extension Set where Element == DatabaseChangeType {
  public static let all: Self = .init(DatabaseChangeType.allCases)
}
