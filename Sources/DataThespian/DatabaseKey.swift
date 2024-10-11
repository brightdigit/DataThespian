//
//  DatabaseKey.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(SwiftUI)

  import Foundation

  import SwiftData

  public import SwiftUI

  fileprivate struct DefaultDatabase: Database {
    func withModelContext<T>(_ closure: (ModelContext) throws -> T) async rethrows -> T {
      assertionFailure("No Database Set.")
      fatalError("No Database Set.")
    }
    func save() async throws {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }
    func delete(_: (some PersistentModel).Type, withID _: PersistentIdentifier) async -> Bool {
      assertionFailure("No Database Set.")
      return false
    }

    func delete(where _: Predicate<some PersistentModel>?) async throws {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }

    func insert(_: @escaping @Sendable () -> some PersistentModel) async -> PersistentIdentifier {
      assertionFailure("No Database Set.")
      fatalError("No Database Set.")
    }

    func fetch<T, U>(
      _: @escaping @Sendable () -> FetchDescriptor<T>,
      with _: @escaping @Sendable ([T]) throws -> U
    ) async throws -> U where T: PersistentModel, U: Sendable {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }
    func fetch<T: PersistentModel, U: PersistentModel, V: Sendable>(
      _ selectDescriptorA: @escaping @Sendable () -> FetchDescriptor<T>,
      _ selectDescriptorB: @escaping @Sendable () -> FetchDescriptor<U>,
      with closure: @escaping @Sendable ([T], [U]) throws -> V
    ) async throws -> V {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }
    func get<T, U>(for _: PersistentIdentifier, with _: @escaping @Sendable (T?) throws -> U)
      async throws -> U where T: PersistentModel, U: Sendable
    {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }

    private struct NotImplmentedError: Error { static let instance = NotImplmentedError() }

    static let instance = DefaultDatabase()

    func transaction(_: @escaping (ModelContext) throws -> Void) async throws {
      assertionFailure("No Database Set.")
      throw NotImplmentedError.instance
    }
  }

  fileprivate struct DatabaseKey: EnvironmentKey {
    static var defaultValue: any Database { DefaultDatabase.instance }
  }

  extension EnvironmentValues {
    public var database: any Database {
      get { self[DatabaseKey.self] }
      set { self[DatabaseKey.self] = newValue }
    }
  }

  extension Scene {
    public func database(_ database: any Database) -> some Scene {
      environment(\.database, database)
    }
  }

  extension View {
    public func database(_ database: any Database) -> some View {
      environment(\.database, database)
    }
  }
#endif
