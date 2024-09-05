//
// DatabaseKey.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftUI)

    import Foundation

    import SwiftData

    public import SwiftUI

    private struct DefaultDatabase: Database {
      func delete(_: (some PersistentModel).Type, withID _: PersistentIdentifier) async -> Bool {
        assertionFailure("No Database Set.")
        return false
      }

      func delete(where _: Predicate<some PersistentModel>?) async throws {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
      }

      func insert(_: @escaping @Sendable () -> some PersistentModel) async -> PersistentIdentifier {
        // assertionFailure("No Database Set.")
        fatalError("No Database Set.")
      }

      func fetch<T, U>(_: @escaping @Sendable () -> FetchDescriptor<T>, with _: @escaping @Sendable ([T]) throws -> U) async throws -> U where T: PersistentModel, U: Sendable {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
      }

      func get<T, U>(for _: PersistentIdentifier, with _: @escaping @Sendable (T?) throws -> U) async throws -> U where T: PersistentModel, U: Sendable {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
      }

      private struct NotImplmentedError: Error {
        static let instance = NotImplmentedError()
      }

      static let instance = DefaultDatabase()

      func transaction(_: @escaping (ModelContext) throws -> Void) async throws {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
      }
    }

    extension DefaultDatabase {
        func obsoleteDelete(where _: Predicate<some PersistentModel>?) async throws {
            assertionFailure("No Database Set.")
            throw NotImplmentedError.instance
        }

        func fetch<T>(_: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
            assertionFailure("No Database Set.")
            throw NotImplmentedError.instance
        }

        func obsoleteFetch<T>(
            _: @escaping () -> FetchDescriptor<T>
        ) async throws -> [T] where T: Sendable, T: PersistentModel {
            assertionFailure("No Database Set.")
            throw NotImplmentedError.instance
        }

        func obsoleteDelete(_: some PersistentModel) async {
            assertionFailure("No Database Set.")
        }

        func obsoleteInsert(_: some PersistentModel) async {
            assertionFailure("No Database Set.")
        }

        func obsoleteSave() async throws {
            assertionFailure("No Database Set.")
            throw NotImplmentedError.instance
        }

        func obsoleteExistingModel<T>(for _: PersistentIdentifier) throws -> T? where T: Sendable, T: PersistentModel {
            assertionFailure("No Database Set.")
            throw NotImplmentedError.instance
        }
    }

    private struct DatabaseKey: EnvironmentKey {
        static var defaultValue: any Database {
            DefaultDatabase.instance
        }
    }

    public extension EnvironmentValues {
        var database: any Database {
            get { self[DatabaseKey.self] }
            set { self[DatabaseKey.self] = newValue }
        }
    }

    public extension Scene {
        func database(
            _ database: any Database
        ) -> some Scene {
            environment(\.database, database)
        }
    }

    @available(*, deprecated, message: "This is a fix for a bug. Use Scene only eventually.")
    extension View {
        public func database(
            _ database: any Database
        ) -> some View {
            environment(\.database, database)
        }
    }
#endif
