//
//  Logging.swift
//  DataThespian
//
//  Created by Leo Dion on 8/14/24.
//

import FelinePine

public enum ThespianLogging: LoggingSystem {
    public enum Category: String, CaseIterable {
        case application
        case data
    }
}

public protocol Loggable: FelinePine.Loggable where Self.LoggingSystemType == ThespianLogging {}
