//
// FetchDescriptor.swift
// Copyright (c) 2024 BrightDigit.
//

#if canImport(SwiftData)
    public import Foundation

    public import SwiftData

    public extension FetchDescriptor {
        init(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int?) {
            self.init(predicate: predicate, sortBy: sortBy)

            self.fetchLimit = fetchLimit
        }
    }
#endif
