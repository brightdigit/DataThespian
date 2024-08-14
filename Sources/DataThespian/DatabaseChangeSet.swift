//
// DatabaseChangeSet.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
  public protocol DatabaseChangeSet: Sendable {
    var inserted: Set<ManagedObjectMetadata> { get }
    var deleted: Set<ManagedObjectMetadata> { get }
    var updated: Set<ManagedObjectMetadata> { get }
  }

  extension DatabaseChangeSet {
    var isEmpty: Bool {
      inserted.isEmpty && deleted.isEmpty && updated.isEmpty
    }

    public func update(
      of types: Set<DatabaseChangeType> = .all,
      contains filteringEntityNames: Set<String>
    ) -> Bool {
      let updateEntityNamesArray = types
        .flatMap { self[keyPath: $0.keyPath] }
        .map(\.entityName)
      let updateEntityNames = Set(updateEntityNamesArray)
      return !updateEntityNames.isDisjoint(with: filteringEntityNames)
    }
  }
#endif
