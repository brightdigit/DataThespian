//
//  Assert.swift
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

public import Foundation

/// Asserts that the current thread is the main thread if the `assertIsBackground` parameter is `true`.
///
/// - Parameters:
///   - isMainThread: A boolean indicating whether the current thread should be the main thread.
///   - assertIsBackground: A boolean indicating whether the assertion should be made.
@inlinable internal func assert(isMainThread: Bool, if assertIsBackground: Bool) {
  assert(!assertIsBackground || isMainThread == Thread.isMainThread)
}

/// Asserts that the current thread is the main thread.
///
/// - Parameter isMainThread: A boolean indicating whether the current thread should be the main thread.
@inlinable internal func assert(isMainThread: Bool) {
  assert(isMainThread == Thread.isMainThread)
}

/// Asserts that an error has occurred, logging the localized description of the error.
///
/// - Parameters:
///   - error: The error that has occurred.
///   - file: The file in which the assertion occurred (default is the current file).
///   - line: The line in the file at which the assertion occurred (default is the current line).
@inlinable internal func assertionFailure(
  error: any Error, file: StaticString = #file, line: UInt = #line
) {
  assertionFailure(error.localizedDescription, file: file, line: line)
}
