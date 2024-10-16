//
//  Queryable.swift
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

public import SwiftData

public protocol Queryable: Sendable {
  func save() async throws

  func insert<PersistentModelType: PersistentModel, U: Sendable>(
    _ closuer: @Sendable @escaping () -> PersistentModelType,
    with closure: @escaping @Sendable (PersistentModelType) throws -> U
  ) async rethrows -> U

  func getOptional<PersistentModelType, U: Sendable>(
    for selector: Selector<PersistentModelType>.Get,
    with closure: @escaping @Sendable (PersistentModelType?) throws -> U
  ) async rethrows -> U

  func fetch<PersistentModelType, U: Sendable>(
    for selector: Selector<PersistentModelType>.List,
    with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
  ) async rethrows -> U

  func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) async throws
}
