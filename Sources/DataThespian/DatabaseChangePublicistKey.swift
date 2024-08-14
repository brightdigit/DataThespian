//
// DatabaseChangePublicistKey.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftUI)
  import Foundation

  public import SwiftUI

  private struct DatabaseChangePublicistKey: EnvironmentKey {
    typealias Value = DatabaseChangePublicist

    nonisolated static let defaultValue: DatabaseChangePublicist = .never()
  }

  extension EnvironmentValues {
    public var databaseChangePublicist: DatabaseChangePublicist {
      get { self[DatabaseChangePublicistKey.self] }
      set { self[DatabaseChangePublicistKey.self] = newValue }
    }
  }
#endif
