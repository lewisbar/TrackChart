//
//  ValueStore.swift
//  Persistence
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Foundation

@Observable
public class ValueStore {
    private(set) public var values: [Int]

    private let persistenceService: SingleTopicPersistenceService?

    public init(persistenceService: SingleTopicPersistenceService? = nil) {
        self.persistenceService = persistenceService
        values = persistenceService?.load() ?? []
    }

    public func add(_ value: Int) {
        values.append(value)
        persistenceService?.save(values)
    }

    public func removeLastValue() {
        guard !values.isEmpty else { return }
        values.removeLast()
        persistenceService?.save(values)
    }
}
