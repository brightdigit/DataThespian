//
// Database.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)

    public import Foundation

    public import SwiftData

    public struct ModelID<T: PersistentModel> {
        let persistentIdentifier: PersistentIdentifier
    }

    public protocol Database: Sendable {
        @discardableResult
        func delete<T: PersistentModel>(_ modelType: T.Type, withID id: PersistentIdentifier) async -> Bool

        func delete<T: PersistentModel>(
            where predicate: Predicate<T>?
        ) async throws

        func insert(_ closuer: @Sendable @escaping () -> some PersistentModel) async -> PersistentIdentifier

        func fetch<T, U: Sendable>(
            _ selectDescriptor: @escaping @Sendable () -> FetchDescriptor<T>,
            with closure: @escaping @Sendable ([T]) throws -> U
        ) async throws -> U

        func fetch<T, U: Sendable>(
            for objectID: PersistentIdentifier,
            with closure: @escaping @Sendable (T?) throws -> U
        ) async throws -> U? where T: PersistentModel
        func transaction(_ block: @Sendable @escaping (ModelContext) throws -> Void) async throws
    }

//    public extension Database {
//        static var loggingCategory: ThespianLogging.Category {
//            .data
//        }
//    }

#endif
