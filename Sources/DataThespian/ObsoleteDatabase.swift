//
//  ObsoleteDatabase.swift
//  Bushel
//
//  Created by Leo Dion on 9/5/24.
//
#if canImport(SwiftData)
import SwiftData


  public protocol ObsoleteDatabase {
    @available(*, deprecated, message: "PersistentModel cannot be Sendable")
    func obsoleteDelete<T>(_ model: T) async where T: PersistentModel & Sendable

    @available(*, deprecated, message: "PersistentModel cannot be Sendable")
    func obsoleteInsert<T>(_ model: T) async where T: PersistentModel & Sendable

    @available(*, deprecated, message: "Saving should be automatic.")
    func obsoleteSave() async throws

    @available(*, deprecated, message: "PersistentModel cannot be Sendable")
    func obsoleteFetch<T>(
      _ descriptor: @Sendable @escaping () -> FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable

    @available(*, deprecated, message: "PersistentModel cannot be Sendable")
    func obsoleteExistingModel<T: PersistentModel & Sendable>(for objectID: PersistentIdentifier) async throws -> T?
  }
#endif