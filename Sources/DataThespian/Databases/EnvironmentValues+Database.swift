//
//  EnvironmentValues+Database.swift
//  DataThespian
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

#if canImport(SwiftUI) && canImport(SwiftData)
  import Foundation
  import SwiftData
  public import SwiftUI
  /// Provides a default implementation of the `Database` protocol
  /// for use in environments where no other database has been set.
  private struct DefaultDatabase: Database {
    /// The singleton instance of the `DefaultDatabase`.
    static let instance = DefaultDatabase()

    // swiftlint:disable unavailable_function

    /// Executes the provided closure within the context of the default model context,
    /// asserting and throwing an error if no database has been set.
    ///
    /// - Parameter closure: A closure that takes a `ModelContext` and returns a value of type `T`.
    /// - Returns: The value returned by the provided closure.
    func withModelContext<T>(_ closure: (ModelContext) throws -> T) async rethrows -> T {
      assertionFailure("No Database Set.")
      fatalError("No Database Set.")
    }
    // swiftlint:enable unavailable_function
  }

  extension EnvironmentValues {
    /// The database to be used within the current environment.
    @Entry public var database: any Database = DefaultDatabase.instance
  }

  extension Scene {
    /// Sets the database to be used within the current scene.
    ///
    /// - Parameter database: The database to be used.
    /// - Returns: A modified `Scene` with the provided database.
    public func database(_ database: any Database) -> some Scene {
      environment(\.database, database)
    }
  }

  extension View {
    /// Sets the database to be used within the current view.
    ///
    /// - Parameter database: The database to be used.
    /// - Returns: A modified `View` with the provided database.
    public func database(_ database: any Database) -> some View {
      environment(\.database, database)
    }
  }
#endif
