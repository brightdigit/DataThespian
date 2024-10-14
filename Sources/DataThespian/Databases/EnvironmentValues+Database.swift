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

  private struct DefaultDatabase: Database {
    static let instance = DefaultDatabase()

    // swiftlint:disable:next unavailable_function
    func withModelContext<T>(_ closure: (ModelContext) throws -> T) async rethrows -> T {
      assertionFailure("No Database Set.")
      fatalError("No Database Set.")
    }
  }

  extension EnvironmentValues {
    @Entry public var database: any Database = DefaultDatabase.instance
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
