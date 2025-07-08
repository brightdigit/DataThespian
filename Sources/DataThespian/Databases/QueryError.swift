//
//  QueryError.swift
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

#if canImport(SwiftData)
  public import SwiftData
  /// An error that occurs when a query fails to find an item.
  public enum QueryError<PersistentModelType: PersistentModel>: Error {
    /// Indicates that the item was not found.
    ///
    /// - Parameter selector: The `Selector.Get` instance that was used to perform the query.
    case itemNotFound(Selector<PersistentModelType>.Get)
    
    /// Indicates that the model's backing data has been invalidated.
    ///
    /// - Parameter model: The `Model` instance that has invalidated backing data.
    case modelInvalidated(Model<PersistentModelType>)
    
    /// Indicates that the model context has been invalidated.
    case contextInvalidated
    
    /// Indicates that accessing the model failed due to backing data issues.
    ///
    /// - Parameter underlyingError: The underlying error that caused the failure.
    case backingDataError(Error)
  }
#endif
