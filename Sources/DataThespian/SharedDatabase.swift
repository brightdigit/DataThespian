////
//// SharedDatabase.swift
//// Copyright (c) 2024 BrightDigit.
////
//
// #if canImport(SwiftData)
//  import Foundation
//
//  public import SwiftData
//
//  public struct SharedDatabase: Sendable {
//    //public static let shared: SharedDatabase = .init()
//
//    public let schemas: [any PersistentModel.Type]
//    public let modelContainer: ModelContainer
//    public let database: any Database
//
//    @available(*, deprecated, message: "Not data-race safe.")
//    private init(
//      obsoleteSchemas: [any(PersistentModel & Sendable).Type],
//      modelContainer: ModelContainer? = nil,
//      database: (any Database)? = nil
//    ) {
//      self.schemas = obsoleteSchemas
//      let modelContainer = modelContainer ?? .forTypes(obsoleteSchemas)
//      self.modelContainer = modelContainer
//      self.database = database ?? BackgroundDatabase(modelContainer: modelContainer)
//    }
//  }
// #endif
