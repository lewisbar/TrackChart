//
//  EntryEntity.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import SwiftData
import Domain

@Model
public final class EntryEntity {
    public var value: Double = 0
    public var timestamp: Date = Date.now
    public var sortIndex: Int = 0
    public var topic: TopicEntity?

    public init(value: Double, timestamp: Date, sortIndex: Int) {
        self.value = value
        self.timestamp = timestamp
        self.sortIndex = sortIndex
    }

    public var entry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}
