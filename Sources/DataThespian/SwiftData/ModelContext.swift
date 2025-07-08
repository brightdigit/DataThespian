//
//  ModelContext.swift
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
  import Foundation
  public import SwiftData

  /// An extension to the `ModelContext` class that provides additional functionality using ``Model``.
  extension ModelContext: Loggable {}
  extension ModelContext {
    /// Retrieves a persistent model with retry logic for invalidated models.
    ///
    /// - Parameter model: The model for which to retrieve the persistent model.
    /// - Parameter maxRetries: Maximum number of retry attempts (default: 3)
    /// - Returns: An optional instance of the specified persistent model,
    /// or `nil` if the model was not found after all retries.
    /// - Throws: A `SwiftData` error or `QueryError` for backing data issues.
    public func getOptionalWithRetry<T>(_ model: Model<T>, maxRetries: Int = 3) throws -> T?
    where T: PersistentModel {
      var retryCount = 0
      
      while retryCount <= maxRetries {
        do {
          return try self.getOptional(model)
        } catch let error as QueryError<T> {
          switch error {
          case .modelInvalidated(let model):
            logger.warning("Model invalidated during retrieval attempt \(retryCount + 1)/\(maxRetries + 1): \(model.persistentIdentifier)")
            if retryCount < maxRetries {
              retryCount += 1
              // Try to refresh the context before retrying
              if hasChanges {
                try save()
              }
              // Small delay before retry
              Thread.sleep(forTimeInterval: 0.01)
              continue
            } else {
              logger.error("Model invalidated after \(maxRetries) retries: \(model.persistentIdentifier)")
              throw error
            }
          case .contextInvalidated:
            logger.warning("Context invalidated during retrieval attempt \(retryCount + 1)/\(maxRetries + 1)")
            if retryCount < maxRetries {
              retryCount += 1
              // Try to refresh the context before retrying
              if hasChanges {
                try save()
              }
              // Small delay before retry
              Thread.sleep(forTimeInterval: 0.01)
              continue
            } else {
              logger.error("Context invalidated after \(maxRetries) retries")
              throw error
            }
          default:
            logger.error("Unexpected error during model retrieval: \(error)")
            throw error
          }
        }
      }
      
      return nil
    }
    /// Retrieves an optional persistent model of the specified type with the given persistent identifier.
    ///
    /// - Parameter model: The model for which to retrieve the persistent model.
    /// - Returns: An optional instance of the specified persistent model,
    /// or `nil` if the model was not found.
    /// - Throws: A `SwiftData` error or `QueryError` for backing data issues.
    public func getOptional<T>(_ model: Model<T>) throws -> T?
    where T: PersistentModel {
      do {
        return try self.persistentModel(withID: model.persistentIdentifier)
      } catch {
        // Check if this is a backing data invalidation error
        if let errorDescription = error.localizedDescription.lowercased(),
           errorDescription.contains("invalidfuturebackingdata") ||
           errorDescription.contains("backing data") ||
           errorDescription.contains("invalidated") {
          logger.warning("Model backing data invalidated: \(model.persistentIdentifier), error: \(error.localizedDescription)")
          throw QueryError.modelInvalidated(model)
        }
        
        // Check for other backing data related errors
        if error.localizedDescription.contains("context") && 
           error.localizedDescription.contains("invalid") {
          logger.warning("Model context invalidated: \(error.localizedDescription)")
          throw QueryError.contextInvalidated
        }
        
        // Wrap other backing data errors
        logger.error("Backing data error for model \(model.persistentIdentifier): \(error.localizedDescription)")
        throw QueryError.backingDataError(error)
      }
    }

    /// Retrieves a persistent model of the specified type with the given persistent identifier.
    ///
    /// - Parameter objectID: The persistent identifier of the model to retrieve.
    /// - Returns: An optional instance of the specified persistent model,
    /// or `nil` if the model was not found.
    /// - Throws: A `SwiftData` error.
    private func persistentModel<T>(withID objectID: PersistentIdentifier) throws -> T?
    where T: PersistentModel {
      // First try to get registered model
      if let registered: T = registeredModel(for: objectID) {
        // Validate the registered model by attempting to access a property
        do {
          // Try to access the persistent model ID to validate the model
          _ = registered.persistentModelID
          return registered
        } catch {
          // If accessing the model fails, it's likely invalidated
          // Continue to other methods
        }
      }
      
      // Try to get model from context
      if let notRegistered: T = model(for: objectID) as? T {
        do {
          // Validate the model by attempting to access a property
          _ = notRegistered.persistentModelID
          return notRegistered
        } catch {
          // If accessing the model fails, continue to fetch
        }
      }

      // Fall back to fetching from the database
      let fetchDescriptor = FetchDescriptor<T>(
        predicate: #Predicate { $0.persistentModelID == objectID },
        fetchLimit: 1
      )

      return try fetch(fetchDescriptor).first
    }
  }
#endif
