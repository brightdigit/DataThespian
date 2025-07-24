import SwiftData
func getMirrorChildValue(of object: Any, childName: String) -> Any? {
    guard let child = Mirror(reflecting: object).children.first(where: { $0.label == childName }) else {
        return nil
    }

    return child.value
}
 extension BackingData {
    // Computed property to access the NSManagedObject
    var isDestroyed: Bool? {
        guard let object = getMirrorChildValue(of: metadata, childName: "isDestroyed") as? Bool else {
            return nil
        }
        return object
    }

    // Computed property to access the NSManagedObjectContext
    var isFuture: Bool? {
        guard let object = getMirrorChildValue(of: metadata, childName: "isFuture") as? Bool else {
            return nil
        }
        return object
    }
}

// MARK: - Approach 1: Extension on PersistentModel Protocol
extension PersistentModel {
  func flatOptional () -> Optional<Self> {
    if isFutureDestroyed == true {
      return nil
    }
    return self
  }
    /// Checks if the model is deleted or non-existent
    var isFutureDestroyed: Bool? {
        // Check if the backing data indicates it's a future/deleted object
        //if let metadata = self.persistentBackingData {
      if self.persistentBackingData.isFuture == true {
        return true
      }
      
      if self.persistentBackingData.isDestroyed == true {
        return true
      }
      
      if self.persistentBackingData.isFuture == false && self.persistentBackingData.isDestroyed == false {
        return false
      }
      
      return nil
        //}
        //return false
    }
    
    /// More comprehensive check for object validity
//    var isValid: Bool {
//        //guard let metadata = self._$backingData._metadata else { return false }
//        return persistentBackingData.isFuture && persistentBackingData.isDestroyed && metadata.context != nil
//    }
    
    /// Checks if the object exists in the persistent store
//    var existsInStore: Bool {
//        guard let context = self._$backingData._metadata?.context else { return false }
//        
//        // Try to fetch the object by its persistent identifier
//        do {
//            let _ = try context.existingModel(for: self.persistentModelID)
//            return true
//        } catch {
//            return false
//        }
//    }
}
