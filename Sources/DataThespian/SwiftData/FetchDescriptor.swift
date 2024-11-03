//
//  FetchDescriptor.swift
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

#if canImport(SwiftData)
  public import Foundation
  public import SwiftData
  ///
  /// Represents a descriptor that can be used to fetch data from a data store.
  ///
  extension FetchDescriptor {
    ///
    /// Initializes a `FetchDescriptor` with the specified parameters.
    ///
    /// - Parameter predicate: An optional `Predicate` that filters the results.
    /// - Parameter sortBy: An array of `SortDescriptor` objects
    /// that determine the sort order of the results.
    /// - Parameter fetchLimit: An optional integer that limits the number of results returned.
    public init(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int?)
    {
      self.init(predicate: predicate, sortBy: sortBy)
      self.fetchLimit = fetchLimit
    }
  }
#endif
